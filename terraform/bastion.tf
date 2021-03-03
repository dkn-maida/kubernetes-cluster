data "aws_ami" "bastion_ami" {
  most_recent = true
  owners = ["self"]
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow ssh on custom bastion port"
  vpc_id      = aws_vpc.kubernetes-cluster-vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 48000
    to_port     = 48000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.kubernetes-cluster-vpc.cidr_block]
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
  private_ip = "10.0.1.1"
  subnet_id = aws_subnet.public.id
  security_groups=[aws_security_group.bastion_sg.id]
  key_name="bastion_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }

  user_data = file("userdata.sh")

  tags = {
    Name = "bastion"
  }
}