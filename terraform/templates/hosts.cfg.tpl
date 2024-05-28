[all:vars]
ansible_python_interpreter='python3'

[bastion]
${bastion_dns}

[bastion:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[cluster]
master ansible_host=${master_ip}
%{ for name, ip in workers_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[cluster:vars]
ansible_ssh_private_key_file='${bastion_private_key}'
ansible_ssh_common_args='-o StrictHostKeyChecking=no -J ec2-user@${bastion_dns}'
