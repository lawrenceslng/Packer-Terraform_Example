# Packer and Terraform Example

This repository demonstrates the use of [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/) as Infrastructure as Code (IaC) tools. 

Packer is a VM image creation tool that enables you to automate the process of image creations, such as an Amazon Machine Image (AMI).

Terraform is a tool to automate infrastructure provision and manage resources in any cloud environment.

In this example, we use Packer to create a custom AWS AMI that uses Amazon Linux with Docker installed. We then use Terraform to provision an AWS VPC along with its public/private subnets, a bastion host accessible only by our own IP address, and 6 EC2 instances in the private subnet that uses the AMI created from Packer.

**Note:** Example and usage steps below are written for the AWS Academy Learner Lab and MacOS environment. There may be slight changes needed to run in other environments.

## Prerequisites

Clone this repository and `cd` into the root directory. You can follow along with either the manual steps or the semi-automated steps. But before starting, you should make sure you have the following installed:

- Packer

    Download Packer using the link and instructions here: https://developer.hashicorp.com/packer/install

    For MacOS users using homebrew, you can simply run the following commands:
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/packer
    ```

    Run `packer` in the terminal to verify installation is successful

    ![Packer Install 1](./assets/Screenshot%202025-03-21%20at%2010.43.45 PM.png)
    
    ![Packer Install 2](./assets/Screenshot%202025-03-21%20at%2010.43.57 PM.png)
    
    ![Packer Install 3](./assets/Screenshot%202025-03-21%20at%2010.44.08 PM.png)

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

    Configure your AWS CLI using Short-term credentials as shown here (if doing manual usage):
    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html

    Or simply run the following commands and follow the instructions:
    ```
    aws configure
    aws configure set aws_session_token <SYOUR_ESSION_TOKEN_HERE>
    ```

    ![AWS CONFIGURE](./assets/Screenshot%202025-03-21%20at%2010.44.18 PM.png)

- Download the SSH Key from Learner Lab

    You can download the PEM file containing the default SSH Key (vockey) from Learner's Lab into the root directory of this repository for use later. Make sure to run `chmod 600 <PEM file>` to make it have the correct permissions for ssh use later.

    ![SSH Key Download](./assets/image.png)

## Manual Usage

You can run the examples in this repository manually. 

### Step 1

Decide if you want to use the provided default SSH key or generate your own for use with your bastion host and/or private EC2 instances.

- If you want to use the default SSH key (vockey) to ssh into the private EC2 instances, run the following from the root directory in the terminal:
    ```
    ssh-keygen -y -f <PEM file>
    ```
    where `<PEM file>` is the default SSH key you downloaded during the prerequisite steps.

    Copy the output and replace the string `REPLACE_WITH_YOUR_PUBLIC_KEY` in `example_packer.pkr.hcl` with the output.

    ![SSH Key Gen](./assets/Screenshot%202025-03-23%20at%202.06.34 PM.png)

- If you want to generate your own SSH key and use that to ssh into the private EC2 instances, run the following from the root directory in the terminal:
    ```
    mkdir -p ./ssh_key

    ssh-keygen -t rsa -b 4096 -f ./ssh_key/private_ec2_key -N ""

    sed -i.bak "s|REPLACE_WITH_YOUR_PUBLIC_KEY|$(cat ./ssh_key/private_ec2_key.pub)|" example_packer.pkr.hcl

    rm -f example_packer.pkr.hcl.bak

    aws ec2 import-key-pair --key-name "private_ec2_key" --public-key-material fileb://ssh_key/private_ec2_key.pub

    chmod 600 ./ssh_key/private_ec2_key
    ```

    This will create a new ssh key that is saved in `./ssh_key`, automatically replace the content in `example_packer.pkr.hcl`, and import the key pair to your AWS account.

    ![SSH Key Gen 1](./assets/Screenshot%202025-03-23%20at%202.41.20 PM.png)

    The SSH public key is automatically inserted into `example_packer.pkr.hcl` as shown below:
    ![SSH Key Gen 2](./assets/Screenshot%202025-03-23%20at%202.41.49 PM.png)

    The SSH key is uploaded to AWS:
    ![SSH Key Gen 3](./assets/Screenshot%202025-03-23%20at%202.42.03 PM.png)


### Step 2

You can run the following commands from the root directory in the terminal:

```
packer init .
packer fmt .
packer validate .
packer build example_packer.pkr.hcl
```

These steps will first initialize the Packer configuration by downloading the AWS plugin as defined in `example_packer.pkr.hcl`, which is our Packer configuration file. Then, Packer will format the template(s) in the current directory and validate the configurations. Finally, Packer will build the AMI and push the image to your AWS account. ([source](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-build-image))

![Packer Init](./assets/Screenshot%202025-03-23%20at%202.06.55 PM.png)

![Packer Build Start](./assets/Screenshot%202025-03-23%20at%202.07.18 PM.png)

A temporary EC2 is created by Packer to create the AMI:
![Temp EC2 Created](./assets/Screenshot%202025-03-23%20at%202.07.48 PM.png)

AMI is created:
![AMI Created](./assets/Screenshot%202025-03-23%20at%202.11.00 PM.png)

Successful Packer build:
![Packer Build Finished](./assets/Screenshot%202025-03-23%20at%202.11.09 PM.png)

### Step 3

Before running the Terraform files, you need to go into `example_variables.tf` and double check/replace the following variables:

- bastion_ingress_ip_address

    Put your public facing IP address in line 3 with `/32` appended. You can find your IP address using `curl -4 ifconfig.me` in your terminal or using https://whatismyipaddress.com/. Example: `8.8.8.8/32`

- custom_ami_id

    Navigate to your AWS Console once Packer build has been run and go to EC2 -> AMIs and copy the AMI ID that has the name "packer-example" and put it in line 15. Example from Step 2's screenshot would be `ami-01cfbdddacfff61cf`.

- bastion_ssh_key

    Replace line 21 with the name of your SSH Key that you intend to use to ssh into the bastion host. In the Learner's Lab, `vockey` is the default SSH key already created, so we will use this to log into the bastion host, but you can replace with a different one that exists if you want.

- private_ssh_key

    Replace line 27 with the name of your SSH Key that you intend to use to ssh into the private EC2 instances (via your bastion host). Use `vockey` if you are using the default SSH Key or use `private_ec2_key` if you generated your own during step 1.

### Step 4

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

### Step 5 (Results)

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