#!/bin/bash

# Function to check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is required but not installed. Exiting."; exit 1; }
}

# Check if Packer is installed
check_command packer

# Check if Terraform is installed
check_command terraform

# Check if AWS CLI is installed
check_command aws

# Get the current public IP address
PUBLIC_IP=$(curl -4 ifconfig.me)/32

# Prompt user for AWS credentials
read -p "Enter your AWS Access Key: " AWS_ACCESS_KEY
read -p "Enter your AWS Secret Key: " AWS_SECRET_KEY
read -p "Enter your AWS Session Token: " AWS_SESSION_TOKEN

read -p "Enter your AWS SSH Key Pair Name (default is vockey): " SSH_KEY_NAME
SSH_KEY_NAME=${SSH_KEY_NAME:-vockey}

# Configure AWS CLI with the provided credentials
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set aws_session_token "$AWS_SESSION_TOKEN"

# Update the example_variables.tf file (fixing sed for macOS)
sed -i.bak "s|default     = \"[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]+/32\"|default     = \"$PUBLIC_IP\"|" example_variables.tf
sed -i.bak "s|default     = \"\"                      # INSERT SSH KEY PAIR NAME HERE|default     = \"$SSH_KEY\"|" example_variables.tf

# Run Packer commands
packer init .
packer fmt .

# Capture the AMI ID from Packer build output (fixing grep for macOS)
AMI_ID=$(packer build . | tee /dev/tty | grep -o 'ami-[a-zA-Z0-9]*' | tail -1)

# Update the example_variables.tf file with the new AMI ID
sed -i.bak "s|default     = \"ami-[a-zA-Z0-9]\+\"|default     = \"$AMI_ID\"|" example_variables.tf

# Clean up backup files
rm -f example_variables.tf.bak