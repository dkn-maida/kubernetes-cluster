data "aws_ami" "bastion_ami" {
  most_recent = true
  owners = ["self"]
  name_regex="^bastion"
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow ssh on custom bastion port"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}


resource "aws_instance" "bastion" {
  ami= data.aws_ami.bastion_ami.id
  instance_type = "t2.micro"
  private_ip = var.bastion_ip
  subnet_id = var.public_subnet_id
  security_groups=[aws_security_group.bastion_sg.id]
  key_name="bastion_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }

  tags = {
    Name = "bastion"
  }
}