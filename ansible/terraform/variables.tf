variable "aws_region" {
  description = "Région AWS"
  default     = "eu-west-3" # Paris
}

variable "project_name" {
  description = "Nom du projet (préfixe pour les ressources)"
  default     = "m1src"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  default     = "~/.ssh/id_ed25519_projet.pub"
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorisé pour SSH (votre IP)"
  default     = "0.0.0.0/0"
}

variable "db_name" {
  description = "Nom de la base de données"
  default     = "appdb"
}

variable "db_username" {
  description = "Nom d'utilisateur MySQL"
  default     = "admin"
}

variable "db_password" {
  description = "Mot de passe MySQL"
  sensitive   = true
}
