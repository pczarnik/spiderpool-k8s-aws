output "bastion_dns" {
  description = "Bastion public DNS"
  value       = aws_instance.bastion.public_dns
}

output "cluster_ips" {
  description = "Private IPs of instances"
  value = {for instance_name, instance in aws_instance.instances : instance_name => instance.private_ip}
}
