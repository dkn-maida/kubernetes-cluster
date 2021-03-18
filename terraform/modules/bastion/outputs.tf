output "bastion_ip" {
    description = "bastion ip"
    value       = aws_instance.bastion.private_ip
}