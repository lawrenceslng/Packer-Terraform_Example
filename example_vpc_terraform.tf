provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_eip" "nat" {
  count = 1

  domain = "vpc"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "my-terraform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = [var.public_subnet_id]

  # Single NAT for all AZ
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  reuse_nat_ips          = true
  external_nat_ip_ids    = aws_eip.nat.*.id
}
