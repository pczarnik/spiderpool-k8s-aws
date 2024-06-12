[all:vars]
ansible_python_interpreter='python3'
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_user='ec2-user'

[cluster]
master ansible_host=${master_dns}
%{ for name, ip in workers_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[workers]
%{ for name, ip in workers_ips ~}
${name} ansible_host=${ip}
%{ endfor ~}

[workers:vars]
ansible_ssh_private_key_file='${master_private_key}'
ansible_ssh_common_args='-o StrictHostKeyChecking=no -J ec2-user@${master_dns}'
