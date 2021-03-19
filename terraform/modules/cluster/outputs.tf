output "control_pane_1_ip" {
    description = "control pane 1 ip"
    value       = aws_instance.control_pane_1.private_ip
}
output "control_pane_2_ip" {
    description = "control pane 2 ip"
    value       = aws_instance.control_pane_2.private_ip
}
output "worker_node_1_ip" {
    description = "worker node 1 ip"
    value       = aws_instance.worker_1.private_ip
}
output "worker_node_2_ip" {
    description = "worker node 2 ip"
    value       = aws_instance.worker_2.private_ip
}
output "worker_node_3_ip" {
    description = "worker node 3 ip"
    value       = aws_instance.worker_3.private_ip
}