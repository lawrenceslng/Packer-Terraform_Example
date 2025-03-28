#!/bin/bash

sudo yum update -y
sudo yum install ansible -y

# Ensure pip3 is installed correctly
sudo yum install -y python3-pip  # ✅ Install pip3 from yum
python3 -m ensurepip --default-pip  # ✅ Ensure pip is initialized
python3 -m pip install --upgrade --user pip  # ✅ Upgrade pip

# Install boto3 and botocore using pip3
sudo python3 -m pip install boto3 botocore