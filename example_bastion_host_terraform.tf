resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.bastion_ingress_ip_address]
  }

  egress {
    protocol    = "-1"  # All protocols
    from_port   = 0     # All ports
    to_port     = 0     # All ports
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-08b5b3a93ed654d19"       # normal Amazon Linux AMI
  key_name                    = var.ssh_key
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}