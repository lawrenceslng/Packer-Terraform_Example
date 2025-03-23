resource "aws_security_group" "private-ec2-sg" {
  name   = "private-ec2-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion-sg.id] # Allow SSH from the bastion host
  }

  egress {
    protocol    = "-1"  # All protocols
    from_port   = 0     # All ports
    to_port     = 0     # All ports
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private_instances" {
  count                       = 6
  ami                         = var.custom_ami_id
  key_name                    = var.private_ssh_key
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.private-ec2-sg.id]

  tags = {
    Name = "private-instance-${count.index + 1}"
  }
}