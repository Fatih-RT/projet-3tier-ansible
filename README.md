# Architecture 3-Tier Haute Disponibilité sur AWS

> Projet M1 Systèmes Réseaux Cloud Computing — Automatisation de la Virtualisation

Déploiement automatisé d'une architecture 3-tier avec haute disponibilité et monitoring, entièrement provisionnée avec **Terraform** et configurée avec **Ansible**.

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────┐
│                   VPC AWS                   │
│  ┌──────────────┐    ┌──────────────┐       │
│  │ Public Subnet│    │Private Subnet│       │
│  │  EC2 + Nginx │───▶│ EC2 + Flask  │───▶  │
│  │ Load Balancer│    │   x2 (HA)    │   ┌──────────┐
│  └──────────────┘    └──────────────┘   │ RDS MySQL│
│                                         └──────────┘
│  ┌──────────────┐
│  │  EC2 Monitor │  Prometheus + Grafana
│  └──────────────┘
└─────────────────────────────────────────────┘
```

## Stack technique

| Couche | Technologie | Rôle |
|---|---|---|
| Infrastructure | Terraform + AWS | Provisioning automatisé |
| Configuration | Ansible (rôles) | Installation des services |
| Tier 1 — Web | Nginx | Reverse proxy + Load balancer |
| Tier 2 — App | Flask + Gunicorn (x2) | Application Python HA |
| Tier 3 — DB | SQLite / RDS MySQL | Base de données |
| Monitoring | Prometheus + Grafana | Métriques et dashboards |

---

## Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.14
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0 configuré avec `aws configure`
- Python >= 3.10
- Compte AWS (Free Tier suffisant)
- Clé SSH sans passphrase

---

## Installation

### 1. Cloner le repo

```bash
git clone https://github.com/VOTRE_USERNAME/projet-3tier-ansible.git
cd projet-3tier-ansible
```

### 2. Générer la clé SSH

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_projet -N ""
```

### 3. Configurer Terraform

```bash
cd terraform
cat > terraform.tfvars << 'EOF'
aws_region          = "eu-west-3"
project_name        = "m1src"
ssh_public_key_path = "~/.ssh/id_ed25519_projet.pub"
ssh_allowed_cidr    = "0.0.0.0/0"
db_name             = "appdb"
db_username         = "admin"
db_password         = "MotDePasseSecurise123!"
EOF
cd ..
```

### 4. Déployer en une commande

```bash
chmod +x deploy.sh
./deploy.sh
```

Le script effectue automatiquement :
1. `terraform init` + `terraform apply` — crée l'infrastructure AWS
2. Génère `ansible/inventory.ini` avec les IPs des instances
3. `ansible-playbook site.yml` — configure tous les serveurs

---

## Vérification

```bash
# Tester l'application
curl http://<IP_NGINX>/

# Vérifier le load balancing (round-robin)
for i in {1..6}; do curl -s http://<IP_NGINX>/ | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['instance'])"; done

# Health check
curl http://<IP_NGINX>/health
```

Interfaces disponibles après déploiement :

| Service | URL | Credentials |
|---|---|---|
| Application | `http://<IP_NGINX>/` | — |
| Grafana | `http://<IP_MONITORING>:3000` | admin / admin123 |
| Prometheus | `http://<IP_MONITORING>:9090` | — |

---

## Structure du projet

```
projet/
├── deploy.sh                    # Script de déploiement complet
├── terraform/
│   ├── main.tf                  # VPC, EC2, RDS, Security Groups
│   ├── variables.tf             # Variables paramétrables
│   ├── outputs.tf               # Outputs + génération inventaire
│   └── inventory.tpl            # Template inventaire Ansible
├── ansible/
│   ├── site.yml                 # Playbook principal
│   ├── ansible.cfg              # Configuration Ansible
│   └── roles/
│       ├── nginx/               # Rôle load balancer
│       ├── flask/               # Rôle application + Node Exporter
│       └── monitoring/          # Rôle Prometheus + Grafana
└── app/
    ├── app.py                   # Application Flask
    └── requirements.txt
```

---

## Rôles Ansible

### nginx
Installe et configure Nginx comme reverse proxy avec upstream dynamique généré par Jinja2 depuis l'inventaire.

### flask
Déploie l'application Python sur 2 instances en parallèle :
- Crée un utilisateur système `flaskapp`
- Virtualenv Python isolé
- Service systemd avec redémarrage automatique
- Node Exporter pour les métriques Prometheus

### monitoring
- Prometheus v2.49 — collecte les métriques via Node Exporter
- Grafana — dashboards de visualisation
- Configuration auto-générée par Jinja2

---

## Destruction de l'infrastructure

```bash
cd terraform
terraform destroy
```

> Penser à détruire après les tests pour éviter des frais AWS.

---

## Auteur

**Fatih** — M1 Systèmes Réseaux Cloud Computing

---

## Licence

MIT — voir [LICENSE](LICENSE)
