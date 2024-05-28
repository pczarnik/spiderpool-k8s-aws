output "bastion_dns" {
  description = "Bastion public DNS"
  value       = aws_instance.bastion.public_dns
}

output "cluster_ips" {
  description = "Private IPs of cluster"
  value = {
    for instance_name, instance in merge(
      { "master" : aws_instance.master },
      aws_instance.workers
    ) : instance_name => instance.private_ip
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      bastion_dns = aws_instance.bastion.public_dns
      master_ip   = aws_instance.master.private_ip
      workers_ips = [for _, instance in aws_instance.workers : instance.private_ip]
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}