output "nginx_public_ip" {
  description = "IP publique du serveur Nginx"
  value       = aws_instance.nginx.public_ip
}

output "flask_private_ips" {
  description = "IPs privées des instances Flask"
  value       = aws_instance.flask[*].private_ip
}

output "monitoring_public_ip" {
  description = "IP publique du serveur de monitoring"
  value       = aws_instance.monitoring.public_ip
}

output "rds_endpoint" {
  description = "Endpoint RDS MySQL"
  value       = aws_db_instance.mysql.endpoint
}

# Génère automatiquement l'inventaire Ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    nginx_ip      = aws_instance.nginx.public_ip
    flask_ips     = aws_instance.flask[*].private_ip
    monitoring_ip = aws_instance.monitoring.public_ip
    rds_endpoint  = aws_db_instance.mysql.endpoint
    db_name       = var.db_name
    db_user       = var.db_username
    db_password   = var.db_password
  })
  filename = "../ansible/inventory.ini"
}
