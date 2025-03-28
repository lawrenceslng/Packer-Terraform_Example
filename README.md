# Multi-OS EC2 Configuration with Ansible (Assignment 10)

This repository demonstrates the use of [Ansible](https://github.com/ansible/ansible).

The assignment description is below:

- Update your previous Terraform assignment to provision 6 EC2: 3 Ubuntu and 3 Amazon Linux. Tag them with (OS: ubuntu or OS:amazon). 1 more EC2 instance to host the Ansible Controller

- Create an Ansible Playbook for the 6 EC2 instance

- Target the 6 ec2 instances and perform the following:
    - Update and upgrade the packages (if needed)
    - Verify we are running the latest docker
    - Report the disk usage for each ec2 instance

Update your repo with a new branch and update the README file for me to follow the instructions so I can run the terraform provisioning and the ansible playbook.

**Note:** Example and usage steps below are written for the AWS Academy Learner Lab and MacOS environment. There may be slight changes needed to run in other environments.

## Prerequisites

Clone this repository and `cd` into the root directory. Before starting, you should make sure you have the following installed:

- Terraform

    Download Terraform using the link and instructions here: https://developer.hashicorp.com/terraform/install?product_intent=terraform

    For MacOS users using homebrew, you can simply run the following commands:
    ```
    brew tap hashicorp/tap                  # if not already run
    brew install hashicorp/tap/terraform
    ```

    Run `terraform -help` in the terminal to verify installation is successful    

    ![Terraform Install 1](./assets/Screenshot%202025-03-21%20at%2010.56.29 PM.png)

- AWS CLI

    Download AWS CLI using the link and instructions here:
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

    Run the following commands to input your credentials from Learner's Lab:
    ```
    aws configure
    aws configure set aws_session_token <YOUR_SESSION_TOKEN_HERE>
    ```

    ![AWS CONFIGURE](./assets/Screenshot%202025-03-21%20at%2010.44.18 PM.png)

- Download the SSH Key from Learner Lab

    You can download the PEM file containing the default SSH Key (vockey) from Learner's Lab into the root directory of this repository for use later. Make sure to run `chmod 600 <PEM file>` to make it have the correct permissions for ssh use later.

    ![SSH Key Download](./assets/image.png)

## Manual Usage

You can run the examples in this repository manually. 

### Step 1

Before running the Terraform files, you need to go into `example_variables.tf` and double check/replace the following variables:

- bastion_ingress_ip_address

    Put your public facing IP address in line 3 with `/32` appended. You can find your IP address using `curl -4 ifconfig.me` in your terminal or using https://whatismyipaddress.com/. Example: `8.8.8.8/32`

<!-- - bastion_ssh_key

    Replace line 21 with the name of your SSH Key that you intend to use to ssh into the bastion host. In the Learner's Lab, `vockey` is the default SSH key already created, so we will use this to log into the bastion host, but you can replace with a different one that exists if you want.

- private_ssh_key

    Replace line 27 with the name of your SSH Key that you intend to use to ssh into the private EC2 instances (via your bastion host). Use `vockey` if you are using the default SSH Key or use `private_ec2_key` if you generated your own during step 1. -->

### Step 2

Now you can run the commands:

```
terraform init
terraform fmt
terraform validate
terraform apply
```

Enter `yes` during the apply step to confirm that the infrastructure should be created.

These steps will first initialize the terraform directory and downloads the `aws` provider. Then it will format and valide your configuration to ensure they are valid. Finally it will create the infrastructure defined in the configuration in your AWS environment. 

![Terraform Init](./assets/Screenshot%202025-03-23%20at%202.12.52 PM.png)

![Terraform Fmt/Validate](./assets/Screenshot%202025-03-23%20at%202.13.08 PM.png)

![Terraform Apply Start](./assets/Screenshot%202025-03-23%20at%202.13.32 PM.png)

![Terraform Apply Complete](./assets/Screenshot%202025-03-23%20at%202.15.57 PM.png)

### Step 3

`scp ansible_playbook.yaml aws_ec2.yaml ec2-user@<ANSIBLE_CONTROLLER_IP>:~`

### Step 4

You should now see the infrastructure created.

VPC:

![VPC](./assets/Screenshot%202025-03-23%20at%202.16.23 PM.png)

Subnets:

![Subnets](./assets/Screenshot%202025-03-23%20at%202.16.50 PM.png)

Bastion Host and Private EC2 Instances:

![EC2s](./assets/Screenshot%202025-03-23%20at%202.16.04 PM.png)

Elastic IP:

![Elastic IP](./assets/Screenshot%202025-03-23%20at%202.16.59 PM.png)

You can ssh into your bastion host using the following command:
```
chmod 600 <PEM_FILE_FOR_BASTION_HOST>
ssh-add <PEM_FILE_FOR_PRIVATE_EC2_INSTANCES>
ssh -A -i <PEM_FILE_FOR_BASTION_HOST> ec2-user@<BASTION_HOST_IP>
```

Once inside the bastion host, you can further ssh into any of the private EC2 instances by simply running:
```
ssh ec2-user@<PRIVATE_EC2_INSTANCE_IP>
```

Example if using `vockey` for both bastion host and private EC2 instances:
![SSH Into Bastion Host](./assets/Screenshot%202025-03-23%20at%202.18.19 PM.png)

![SSH Into Private EC2](./assets/Screenshot%202025-03-23%20at%202.18.48 PM.png)

Example if using `vockey` for bastion host and `private_ec2_key` for private EC2 instances:
![SSH Into Bastion Host](./assets/Screenshot%202025-03-23%20at%202.51.21 PM.png)

![SSH Into Private EC2](./assets/Screenshot%202025-03-23%20at%202.51.51 PM.png)

### Step 5

do 

```
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
pip3 install --user boto3 botocore

aws configure
aws configure set aws_session_token <SESSION_TOKEN_HERE>

export ANSIBLE_HOST_KEY_CHECKING=False
```
in the Ansible controller

### Step 6 (Clean Up)

Once you are done, delete all created infrastructure by running `terraform destroy` in the terminal. Again, enter `yes` to confirm.

![Terraform Destroy 1](./assets/Screenshot%202025-03-23%20at%202.20.15 PM.png)

![Terraform Destroy 2](./assets/Screenshot%202025-03-23%20at%202.21.03 PM.png)

Delete the AMI that was created as well during the packer process to avoid additional charges.

## Semi-Automated Usage

A script has been provided for MacOS users to do some of the above manual steps more easily. It will check if prerequisites are installed, ask for AWS credentials and run `aws configure`, run the Packer commands, and replace the necessary variables in `example_variables.tf` programmatically.

It will automatically use the default `vockey` as the SSH Key for ssh into the bastion host and create a separate key for the private EC2 instances.

So to run the example in this repository, first ensure `setup_script.sh` is executable by running `chmod +x setup_script.sh`, then run `./setup_script.sh` in the terminal.

![Auto Script 1](./assets/Screenshot%202025-03-23%20at%203.05.49 PM.png)

Once all is done, simply run the following commands:

```
terraform init
terraform fmt
terraform validate
terraform apply
```

Inspect your created infrastructure in the AWS Console. You can ssh into your bastion host using the following command:
```
chmod 600 <PEM_FILE_FOR_BASTION_HOST>
ssh-add ./ssh_key/private_ec2_key
ssh -A -i <PEM_FILE_FOR_BASTION_HOST> ec2-user@<BASTION_HOST_IP>
```

![Auto Script 2](./assets/Screenshot%202025-03-23%20at%203.16.30 PM.png)

Once inside the bastion host, you can further ssh into any of the private EC2 instances by simply running:
```
ssh ec2-user@<PRIVATE_EC2_INSTANCE_IP>
```

![Auto Script 3](./assets/Screenshot%202025-03-23%20at%203.16.57 PM.png)

Once you are done, delete all created infrastructure by running `terraform destroy` in the terminal. Again, enter `yes` to confirm.

Delete the AMI that was created as well during the packer process to avoid additional charges.

## Conclusion

We successfully demonstrated the use of Packer and Terraform to create a custom AWS AMI and provision AWS resources. Let me know if you have any questions!