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

