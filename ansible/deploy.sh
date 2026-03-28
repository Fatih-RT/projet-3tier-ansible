#!/bin/bash
# deploy.sh — Lance Terraform puis Ansible en séquence
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== Déploiement Architecture 3-Tier ===${NC}"

# ── Agent SSH automatique ────────────────────────────────────
echo -e "\n${GREEN}[0/4] Configuration de l'agent SSH...${NC}"
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s)
fi

# Cherche la clé projet en priorité, sinon la clé par défaut
if [ -f ~/.ssh/id_ed25519_projet ]; then
    ssh-add ~/.ssh/id_ed25519_projet 2>/dev/null
elif [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
else
    echo -e "${RED}Aucune clé SSH trouvée dans ~/.ssh/${NC}"
    exit 1
fi

# ── Étape 1 : Terraform ─────────────────────────────────────
echo -e "\n${GREEN}[1/4] Initialisation Terraform...${NC}"
cd terraform
terraform init

echo -e "\n${GREEN}[2/4] Application de l'infrastructure AWS...${NC}"
terraform apply -auto-approve

echo -e "\n${GREEN}[3/4] Récupération des outputs...${NC}"
NGINX_IP=$(terraform output -raw nginx_public_ip)
MONITORING_IP=$(terraform output -raw monitoring_public_ip)
echo "  Nginx        : $NGINX_IP"
echo "  Monitoring   : $MONITORING_IP"

# ── Étape 2 : Attente que les instances soient prêtes ────────
echo -e "\n${GREEN}Attente du démarrage des instances (60s)...${NC}"
sleep 60

# ── Étape 3 : Ansible ───────────────────────────────────────
cd ../ansible
echo -e "\n${GREEN}[4/4] Configuration avec Ansible...${NC}"
ansible-playbook -i inventory.ini site.yml

# ── Résumé ──────────────────────────────────────────────────
echo -e "\n${GREEN}=== Déploiement terminé ! ===${NC}"
echo -e "  Application  : http://$NGINX_IP"
echo -e "  Grafana      : http://$MONITORING_IP:3000  (admin / admin123)"
echo -e "  Prometheus   : http://$MONITORING_IP:9090"
