output "master_dns" {
  description = "master public DNS"
  value       = aws_instance.master.public_dns
}

output "worker_ips" {
  description = "Private IPs of workers"
  value = {
    for instance_name, instance in aws_instance.workers
    : instance_name => instance.private_ip
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.cfg.tpl",
    {
      master_private_key = "${dirname(path.cwd)}/${basename(var.master_private_key)}"
      master_dns         = aws_instance.master.public_dns
      workers_ips = {
        for _, instance in aws_instance.workers
        : instance.tags["Name"] => instance.private_ip
      }
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}