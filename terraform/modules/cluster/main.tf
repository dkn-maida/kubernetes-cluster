data "aws_ami" "control_pane_ami" {
  most_recent = true
  owners = ["self"]
  name_regex="^control-pane"
}

resource "aws_instance" "control_pane_1" {
  ami= data.aws_ami.control_pane_ami.id
  instance_type = "t3.small"
  private_ip = var.control_pane_1_ip
  subnet_id = var.private_subnet_id
  security_groups=[aws_security_group.control_pane_sg.id]
  key_name="bastion_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "master-1"   
  }
}

resource "aws_security_group" "control_pane_sg" {
    name        = "control_pane_sg"
    description = "Allow ssh on host from bastion"
    vpc_id      = var.vpc_id

    ingress {
        description = "SSH from bastion only"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.bastion_ip}/32"]
    }

    ingress {
        description = ""
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        cidr_blocks = [var.private_subnet_cidr_block]
    }

    ingress {
        description = ""
        from_port   = 2379
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = [var.private_subnet_cidr_block]
    }

    ingress {
        description = ""
        from_port   = 10250
        to_port     = 10252
        protocol    = "tcp"
        cidr_blocks = [var.private_subnet_cidr_block]
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