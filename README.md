# Packer and Terraform Example

This repository demonstrates the use of [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/) as Infrastructure as Code (IaC) tools. 

Packer is a VM image creation tool that enables you to automate the process of image creations, such as an Amazon Machine Image (AMI).

Terraform is a tool to automate infrastructure provision and manage resources in any cloud environment.

In this example, we use Packer to create a custom AWS AMI that uses Amazon Linux with Docker installed. We then use Terraform to provision an AWS VPC along with its public/private subnets, a bastion host accessible only by our own IP address, and 6 EC2 instances in the private subnet that uses the AMI created from Packer.

**Note:** Example and usage steps below are written for the AWS Academy Learner Lab. There may be slight changes needed to run in regular AWS environment.

## Prerequisites

Before starting, you should make sure you have the following installed:

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

    You can download the PEM file containing your SSH Key into the root directory of this repository for use later.

    ![SSH Key Download](./assets/image.png)

## Manual Usage

You can run the examples in this repository manually. Once you have all the prerequisites installed, you can run the following commands from the root directory in the terminal:

```
packer init .
packer fmt .
packer validate .
packer build example_packer.pkr.hcl
```

These steps will first initialize the Packer configuration by downloading the AWS plugin as defined in `example_packer.pkr.hcl`, which is our Packer configuration file. Then, Packer will format the template(s) in the current directory and validate the configurations. Finally, Packer will build the AMI and push the image to your AWS account. ([source](https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-build-image))

![Packer Build Start](./assets/Screenshot%202025-03-21%20at%2010.48.03 PM.png)

![Packer Image VM Start](./assets/Screenshot%202025-03-21%20at%2010.48.21 PM.png)

![Packer Build Finished](./assets/Screenshot%202025-03-21%20at%2010.51.13 PM.png)

![AMI in Console](./assets/Screenshot%202025-03-21%20at%2010.51.24 PM.png)

Before running the Terraform files, you need to go into `example_variables.tf` and replace the following variables:

- bastion_ingress_ip_address

    Put your public facing IP address in line 3. You can find your IP address using `curl -4 ifconfig.me` in your terminal or using https://whatismyipaddress.com/

- custom_ami_id

    Navigate to your AWS Console once Packer build has been run and go to EC2 -> AMIs and copy the AMI ID that has the name "packer-example" and put it in line 15. See image for example:

- ssh_key

    Replace line 21 with the name of your SSH Key that you intend to use to ssh into the bastion host and private EC2 instances. In the Learner's Lab, `vockey` is the default SSH key already created, but you can replace this with an SSH key that has the proper permissions.

Once these variables are set, you can run the commands:

```
terraform init
terraform fmt
terraform validate
terraform apply
```

These steps will first initialize the terraform directory and downloads the `aws` provider. Then it will format and valide your configuration to ensure they are valid. Finally it will create the infrastructure defined in the configuration in your AWS environment. 

![Terraform Init](./assets/Screenshot%202025-03-21%20at%2011.37.22 PM.png)

![Terraform Validate and Apply](./assets/Screenshot%202025-03-22%20at%2012.40.04 AM.png)

You should now see the infrastructure created.

![Terraform Complete](./assets/Screenshot%202025-03-22%20at%2012.40.16 AM.png)

VPC:

Bastion Host:

Private EC2 Instances:

You can ssh into your bastion host using the following command:
`ssh-add <FILEPATH TO PEM FILE DOWNLOADED FROM LEARNER LAB>`
`ssh -A -i <PEM FILE FILEPATH> ec2-user@<BASTION_HOST_IP>`

Once inside the bastion host, you can further ssh into any of the private EC2 instances by simply running:
`ssh ec2-user@<PRIVATE_EC2_INSTANCE_IP>`

Once you are done, delete all created infrastructure by running `terraform destroy` in the terminal.

## Semi-Automated Usage

A script has been provided to check if prerequisites are installed, ask for AWS credientials and run `aws configure`, run the Packer commands, and replace the necessary variables in `example_variables.tf` programmatically.

So to run the example in this repository, first ensure `setup_script.sh` is executable by running `chmod +x setup_script.sh`, then run `./setup_script.sh` in the terminal.

Once all is done, simply run the following commands:

```
terraform init
terraform validate
terraform apply
```

Inspect your created infrastructure in the AWS Console.

Once you are done, delete all created infrastructure by running `terraform destroy` in the terminal.

## Steps

1. Install Packer 
https://developer.hashicorp.com/packer/install
https://developer.hashicorp.com/packer/tutorials/aws-get-started/get-started-install-cli

```
brew tap hashicorp/tap
```

```
brew install hashicorp/tap/packer
```

```
packer
```



2. Created `example_packer.pkr.hcl`

3. do `aws configure` and `aws configure set aws_session_token <SESSION_TOKEN_HERE>`

4. `packer init .`

5. `packer fmt .`

6. `packer build example_packer.pkr.hcl`

7. download Terraform https://developer.hashicorp.com/terraform/install?product_intent=terraform

```
brew install hashicorp/tap/terraform
```

```
terraform -help
```

8. create terraform.tf

**MANUAL STEPS**
9. `terraform init`

10. get the .pem file then run `ssh-keygen -y -f labsuser.pem` and put it in bastion_host.tf spot
- put in vars along with own ip address


11. `terraform validate`

12. `terraform apply`

13. try ssh into bastion host then jump to the private ec2s
`ssh-add labsuser.pem`
`ssh -A -i labsuser.pem ec2-user@<BASTION_HOST_IP>`


**MANUAL STEPS END**



## At End

`terraform destroy`


TO DO 
add outbound rule for bastion-security-group