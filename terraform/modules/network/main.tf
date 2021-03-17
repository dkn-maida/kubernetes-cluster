resource "aws_vpc" "kubernetes-cluster-vpc" {
  cidr_block = var.vpc_cidr_block
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.kubernetes-cluster-vpc.id
  cidr_block = var.private_subnet_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.kubernetes-cluster-vpc.id
  cidr_block = var.public_subnet_cidr_block
  map_public_ip_on_launch = false

  tags = {
    Name = "private subnet"
  }
}

resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.kubernetes-cluster-vpc.id
}


/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.kubernetes-cluster-vpc.id
}
/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kubernetes-cluster-vpc.id
}


resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}


/* Route table associations */
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


/*==== VPC's Default Security Group ======*/
resource "aws_security_group" "default" {
  name        = "kubernetes-cluster-vpc-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.kubernetes-cluster-vpc.id
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}