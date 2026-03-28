[nginx]
${nginx_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519_projet

[flask]
%{ for ip in flask_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519_projet ansible_ssh_common_args='-o ProxyJump=ubuntu@${nginx_ip}'
%{ endfor ~}

[monitoring]
${monitoring_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519_projet

[all:vars]
db_host=${rds_endpoint}
db_name=${db_name}
db_user=${db_user}
db_password=${db_password}
nginx_ip=${nginx_ip}
