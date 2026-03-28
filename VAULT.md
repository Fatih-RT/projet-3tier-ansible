# Guide Ansible Vault

## Chiffrer le fichier vault

```bash
cd ansible
ansible-vault encrypt group_vars/all/vault.yml
```

Saisissez un mot de passe et retenez-le — il sera nécessaire à chaque exécution.

## Déchiffrer / éditer

```bash
ansible-vault edit group_vars/all/vault.yml
```

## Lancer le playbook avec vault

```bash
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

Ou avec un fichier contenant le mot de passe :

```bash
echo "votre_mot_de_passe" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-playbook -i inventory.ini site.yml --vault-password-file ~/.vault_pass
```

## Secrets GitHub Actions à configurer

Dans votre repo GitHub → Settings → Secrets → New repository secret :

| Nom du secret | Valeur |
|---|---|
| `AWS_ACCESS_KEY_ID` | Votre Access Key AWS |
| `AWS_SECRET_ACCESS_KEY` | Votre Secret Key AWS |
| `SSH_PRIVATE_KEY` | Contenu de `~/.ssh/id_ed25519_projet` |
| `SSH_PUBLIC_KEY` | Contenu de `~/.ssh/id_ed25519_projet.pub` |
| `VAULT_PASSWORD` | Mot de passe Ansible Vault |
| `DB_PASSWORD` | Mot de passe MySQL |
