variable "ansible_ingress_ip_address" {
  type        = string
  default     = "0.0.0.0/0" # INSERT OWN IP ADDRESS HERE
  description = "Insert Your IP Address Here"
}

variable "public_subnet_id" {
  type        = string
  default     = "10.0.101.0/24"
  description = "The VPC's public subnet IP"
}

variable "ansible_ssh_key" {
  type        = string
  default     = "vockey" # INSERT Ansible Controller SSH KEY PAIR NAME HERE
  description = "Put Your Ansible Controller SSH Key Here"
}

variable "private_ssh_key" {
  type        = string
  default     = "vockey" # INSERT Private EC2 SSH KEY PAIR NAME HERE
  description = "Put Your Private EC2 SSH Key Here"
}

