variable "bastion_ingress_ip_address" {
    type        = string
    default     = ""                            # INSERT OWN IP ADDRESS HERE
    description = "Insert Your IP Address Here"
}

variable "public_subnet_id" {
    type        = string
    default     = "10.0.101.0/24"
    description = "The VPC's public subnet IP"
}

variable "custom_ami_id" {
    type        = string
    default     = ""                            # INSERT CUSTOM AMI ID HERE
    description = "Put Your AMI Here"
}

variable "ssh_key" {
    type        = string
    default     = "vockey"                            # INSERT SSH KEY PAIR NAME HERE
    description = "Put Your SSH Key Here"
}

