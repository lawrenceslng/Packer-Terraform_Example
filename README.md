# Packer-Terraform_Example

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