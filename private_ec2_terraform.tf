resource "aws_security_group" "private-ec2-sg" {
  name   = "private-ec2-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.ansible-sg.id] # Allow SSH from the ansible controller
  }

  egress {
    protocol    = "-1"  # All protocols
    from_port   = 0     # All ports
    to_port     = 0     # All ports
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private_ubuntu_instances" {
  count                       = 3
  ami                         = ""
  key_name                    = var.private_ssh_key
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.private-ec2-sg.id]

  tags = {
    Name = "private-ubuntu-${count.index + 1}"
  }
}

resource "aws_instance" "private_amazon_linux_instances" {
  count                       = 3
  ami                         = "ami-08b5b3a93ed654d19"
  key_name                    = var.private_ssh_key
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.private-ec2-sg.id]

  tags = {
    Name = "private-amazon_linux-${count.index + 1}"
  }
}