output "control_pane_1_ip" {
    description = "control_pane_1_ip"
    value       = aws_instance.control_pane_1.private_ip
}
output "control_pane_2 ip" {
    description = "control_pane_2 ip"
    value       = aws_instance.control_pane_2.private_ip
}
output "worker_node_1_ip" {
    description = "worker_node_1_ip"
    value       = aws_instance.worker_1.private_ip
}
output "worker_node_2_ip" {
    description = "worker_node_2_ip"
    value       = aws_instance.worker_2.private_ip
}
output "worker_node_3_ip" {
    description = "worker_node_3_ip"
    value       = aws_instance.worker_3.private_ip
}