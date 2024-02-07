#!/bin/bash
#
# Version 1.12 2/07/2024
# Script Requirements and Configuration:
# ----------------------------------------
# - This script requires SSH key-based authentication for connecting to remote servers.
# - Ensure that SSH keys are set up and accessible for the user running this script.
# - SSH keys must be authorized on the remote servers for passwordless authentication.
# - If SSH keys are not set up, manual authentication may be required during script execution.
#
# - Configuration:
#   - Modify the 'port' variable to specify the SSH port used for connections.
#   - Update the 'servers' array with the list of target servers.
#   - Adjust the 'path' variable to specify the path to search for cert.pem files on remote servers.
#
# Error Handling and Troubleshooting:
# ------------------------------------
# - The script performs basic error checking for SSH connectivity and file existence.
# - Ensure that the script user has necessary permissions and proper network access.
# - Error messages are displayed for failed SSH connections or missing cert.pem files.
# - If errors occur, review the output and troubleshoot as needed.
#
# Disclaimer:
# -----------
# - Use this script at your own risk.
# - Always exercise caution while running scripts, especially those involving remote execution.
# - The authors and contributors to this script are not responsible for any damages or misuse.
#
# License:
# --------
# This script is licensed under the GNU General Public License (GPL) version 3.
# You may obtain a copy of the license at: https://www.gnu.org/licenses/gpl-3.0.en.html

# Define the port to use for SSH connections
port=22

# Define the list of servers separated by a single space
servers=(root@example.com root@svr2.example.com root@root@svr3.example.com root@server.example.com root@www.example.com)

# Define the path to search for cert.pem files
path="/etc/letsencrypt/live"

# Function to display error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Loop over each server
for server in "${servers[@]}"; do
    # Check SSH Connection Status
    if ! ssh -q -p "$port" "$server" exit; then
        error_exit "SSH connection to $server on port $port failed."
    fi

    # Check if there are any cert.pem files in any sub-folder of the specified path on the server
    if ! ssh -q -p "$port" "$server" "find $path -name cert.pem | grep cert.pem > /dev/null"; then
        error_exit "cert.pem files not found in any sub-folder of $path on server $server"
    fi

    # Retrieve the path to all cert.pem files
    cert_paths=$(ssh -p "$port" "$server" "find $path -name cert.pem")

    # Loop over each cert.pem file in the sub-folders of the specified path
    for cert_path in $cert_paths; do
        # Extract the start and end dates from the cert.pem file on the server
        start_date=$(ssh -p "$port" "$server" "openssl x509 -in $cert_path -noout -startdate" | cut -d'=' -f 2)
        end_date=$(ssh -p "$port" "$server" "openssl x509 -in $cert_path -noout -enddate" | cut -d'=' -f 2)

        # Display certificate information
        echo "Server: $server"
        echo "Certificate Path: $cert_path"
        echo "Start Date: $start_date"
        echo "End Date: $end_date"
        echo

        # Calculate the number of days remaining until the certificate expires
        today=$(date +%s)
        end_date_secs=$(date -d "$end_date" +%s)
        days_remaining=$(( (end_date_secs - today) / 86400 ))

        # Check if the certificate has expired
        if [ $days_remaining -lt 0 ]; then
            echo -e "\033[5m\033[31mEXPIRED\033[0m: Certificate has expired $((-1 * $days_remaining)) days ago."
            echo
        else
            echo "Days remaining until expiration: $days_remaining"
            echo
        fi
        echo ""
    done
done
