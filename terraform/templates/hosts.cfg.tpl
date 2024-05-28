[all:vars]
ansible_python_interpreter='python3'

[bastion]
${bastion_dns}

[bastion:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[cluster]
${master_ip}
%{ for ip in workers_ips ~}
${ip}
%{ endfor ~}

[cluster:vars]
ansible_ssh_private_key_file='${bastion_private_key}'
ansible_ssh_common_args='-o StrictHostKeyChecking=no -J ec2-user@${bastion_dns}'

[master]
${master_ip}

[master:vars]
ansible_ssh_private_key_file='${bastion_private_key}'
ansible_ssh_common_args='-o StrictHostKeyChecking=no -J ec2-user@${bastion_dns}'

[workers]
%{ for ip in workers_ips ~}
${ip}
%{ endfor ~}

[workers:vars]
ansible_ssh_private_key_file='${bastion_private_key}'
ansible_ssh_common_args='-o StrictHostKeyChecking=no -J ec2-user@${bastion_dns}'
