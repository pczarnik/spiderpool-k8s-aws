output "bastion_dns" {
  description = "Bastion public DNS"
  value       = aws_instance.bastion.public_dns
}
