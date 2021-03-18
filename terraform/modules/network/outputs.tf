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
    value       = aws_subnet.private.id
}