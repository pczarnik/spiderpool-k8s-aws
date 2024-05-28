[bastion]
${bastion_dns}

[cluster]
${master_ip}
%{ for ip in workers_ips ~}
${ip}
%{ endfor ~}

[master]
${master_ip}

[workers]
%{ for ip in workers_ips ~}
${ip}
%{ endfor ~}
