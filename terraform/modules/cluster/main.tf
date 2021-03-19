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
  key_name="control_pane_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "master-1"   
  }
}

resource "aws_instance" "control_pane_2" {
  ami= data.aws_ami.control_pane_ami.id
  instance_type = "t3.small"
  private_ip = var.control_pane_2_ip
  subnet_id = var.private_subnet_id
  security_groups=[aws_security_group.control_pane_sg.id]
  key_name="control_pane_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "master-2"   
  }
}

resource "aws_instance" "worker_1" {
  ami= data.aws_ami.control_pane_ami.id
  instance_type = "t3.small"
  private_ip = var.worker_1_ip
  subnet_id = var.private_subnet_id
  security_groups=[aws_security_group.worker_node_sg.id]
  key_name="worker_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "worker-1"   
  }
}


resource "aws_instance" "worker_2" {
  ami= data.aws_ami.control_pane_ami.id
  instance_type = "t3.small"
  private_ip = var.worker_2_ip
  subnet_id = var.private_subnet_id
  security_groups=[aws_security_group.worker_node_sg.id]
  key_name="worker_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "worker-2"   
  }
}

resource "aws_instance" "worker_3" {
  ami= data.aws_ami.control_pane_ami.id
  instance_type = "t3.small"
  private_ip = var.worker_3_ip
  subnet_id = var.private_subnet_id
  security_groups=[aws_security_group.worker_node_sg.id]
  key_name="worker_key"
  root_block_device  {
      volume_type = "gp2"
      volume_size = 8
  }
  tags = {
    Name = "worker-3"   
  }
}

resource "aws_lb" "cluster_network_load_balancer" {
  name               = "cluster-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.private_subnet_id]

  tags = {
    Name = "cluster network load balancer"
  }
}

resource "aws_lb_target_group" "control_pane_target_group" {
  name        = "control-pane-target-group"
  port        = 6443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  
  tags = {
        Name = "control_pane_target_group"
  } 
}

resource "aws_lb_target_group_attachment" "control_pane_1_tg_attachment" {
  target_group_arn = aws_lb_target_group.control_pane_target_group.arn
  target_id        = aws_instance.control_pane_1.id
  port             = 6443
}
resource "aws_lb_target_group_attachment" "control_pane_2_tg_attachment" {
  target_group_arn = aws_lb_target_group.control_pane_target_group.arn
  target_id        = aws_instance.control_pane_2.id
  port             = 6443
}
resource "aws_lb_listener" "control_pane_listener" {
  load_balancer_arn = aws_lb.cluster_network_load_balancer.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_pane_target_group.arn
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
        Name = "control_pane_sg"
    }   
}


resource "aws_security_group" "worker_node_sg" {
    name        = "worker_node_sg"
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
        description = "kubelet API Self, Control Pane"
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "NodePortServices"
        from_port   = 30000
        to_port     = 32767
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "worker_sg"
    }   
}