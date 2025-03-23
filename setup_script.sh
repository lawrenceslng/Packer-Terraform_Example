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

# Configure AWS CLI with the provided credentials
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set aws_session_token "$AWS_SESSION_TOKEN"

mkdir -p ./ssh_key

ssh-keygen -t rsa -b 4096 -f ./ssh_key/private_ec2_key -N ""

sed -i.bak "s|REPLACE_WITH_YOUR_PUBLIC_KEY|$(cat ./ssh_key/private_ec2_key.pub)|" example_packer.pkr.hcl

# Clean up backup files
rm -f example_packer.pkr.hcl.bak

aws ec2 import-key-pair --key-name "private_ec2_key" --public-key-material fileb://ssh_key/private_ec2_key.pub

chmod 600 ./ssh_key/private_ec2_key

# Update the example_variables.tf file (fixing sed for macOS)
sed -i.bak "s|default     = \"x.x.x.x/32\"|default     = \"$PUBLIC_IP\"|" example_variables.tf

# Run Packer commands
packer init .
packer fmt .

# Capture the AMI ID from Packer build output (fixing grep for macOS)
AMI_ID=$(packer build . | tee /dev/tty | grep -o 'ami-[a-zA-Z0-9]*' | tail -1)

# Update the example_variables.tf file with the new AMI ID
sed -i.bak "s|default     = \"ami-123123\"|default     = \"$AMI_ID\"|" example_variables.tf

# Clean up backup files
rm -f example_variables.tf.bak