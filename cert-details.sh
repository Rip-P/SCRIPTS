#!/bin/bash
# This Bash script retrieves SSL certificate details for a specified domain using OpenSSL.
# It prompts the user to enter a domain name and then displays the certificate details.
# Created by RipTideTech.io
# 2/7/2024

# Usage: ./cert-details.sh
# Instructions:
#   1. Save the script into a file, for example, retrieve_certificate_details.sh.
#   2. Make the script file executable by running the command: chmod +x retrieve_certificate_details.sh.
#   3. Run the script by executing: ./retrieve_certificate_details.sh.
#   4. When prompted, enter the domain name for which you want to retrieve the certificate details.

# Prompt the user to enter the domain name
read -p "Enter the domain name: " domain

# Basic validation for domain name
if [ -z "$domain" ]; then
    echo "Error: Domain name cannot be empty."
    exit 1
fi

# Display a message indicating that certificate details are being retrieved for the specified domain
echo "Retrieving certificate details for $domain..."

# Output a blank line for formatting purposes
echo ""

# Use OpenSSL to connect to the specified domain on port 443 (the default HTTPS port), retrieve the SSL certificate,
# and display the certificate details in a human-readable format using openssl x509 -text
if ! output=$(openssl s_client -connect $domain:443 -servername $domain </dev/null 2>/dev/null | openssl x509 -text); then
    echo "Error: Unable to retrieve certificate details for $domain."
    exit 1
fi

# Check if the output is empty (indicating no certificate details retrieved)
if [ -z "$output" ]; then
    echo "Error: No certificate details retrieved for $domain."
    exit 1
fi

# Output the certificate details
echo "$output"

# Output another blank line for formatting purposes
echo ""

# Exit the script with a status code of 0, indicating successful execution
exit 0
