output "vpc_id" {
    description = "vpc id"
    value       = aws_vpc.kubernetes-cluster-vpc.id
}
  
output "public_subnet_id" {
    description = "public subnet id"
    value       = aws_subnet.public.id
}

output "private_subnet_id" {
    description = "private subnet id"
    value       = aws_subnet.private.cidr_block
}

output "public_subnet_cidr_block" {
    description = "public subnet cidr block"
    value       = aws_subnet.public.cidr_block
}

output "private_subnet_cidr_block" {
    description = "private subnet cidr block"
    value       = aws_subnet.private.cidr_block
}