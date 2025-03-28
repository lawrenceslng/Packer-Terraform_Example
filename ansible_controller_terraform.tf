resource "aws_security_group" "ansible-sg" {
  name   = "ansible-controller-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.ansible_ingress_ip_address]
  }

  egress {
    protocol    = "-1" # All protocols
    from_port   = 0    # All ports
    to_port     = 0    # All ports
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible-controller" {
  ami                         = "ami-08b5b3a93ed654d19" # normal Amazon Linux AMI
  key_name                    = var.ansible_ssh_key
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ansible-sg.id]
  associate_public_ip_address = true

  user_data = file("ansible_setup.sh")

  tags = {
    Name = "Ansible Controller"
  }
}