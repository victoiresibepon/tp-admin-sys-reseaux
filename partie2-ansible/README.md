# Partie 2 : Playbook Ansible

## Fichiers

- `create_users.yml` - Playbook principal
- `inventory.ini` - Liste des serveurs cibles
- `users.csv` - Données des utilisateurs

## Configuration avant exécution

### 1. Modifier inventory.ini

Remplacer `YOUR_SERVER_IP` par l'IP réelle de votre VPS.

### 2. Configurer l'envoi d'emails

Dans `create_users.yml`, modifier les variables SMTP:

```yaml
smtp_host: "smtp.gmail.com"
smtp_port: 587
smtp_user: "votre.email@gmail.com"
smtp_password: "mot_de_passe_app_gmail"
```

Pour Gmail, générer un mot de passe d'application:
1. Compte Google → Sécurité → Validation en deux étapes
2. Mots de passe des applications → Générer

### 3. Installer Ansible

```bash
sudo apt install ansible
```

## Exécution

```bash
# Test de connexion
ansible -i inventory.ini vps_servers -m ping

# Lancer le playbook
ansible-playbook -i inventory.ini create_users.yml

# Avec verbose (debug)
ansible-playbook -i inventory.ini create_users.yml -vvv
```

## Ce qui est fait

Tout pareil que le script Bash + l'envoi d'email automatique à chaque user avec:
- IP du serveur
- Port SSH
- Username et mot de passe
- Commande SSH de connexion
- Commandes pour copier la clé publique (Linux/Mac/Windows)

## Format users.csv

```csv
username,password,fullname,phone,email,shell
alice,Pass123!,Alice Dupont,+237690123456,alice@email.com,/bin/bash
```

## Problèmes possibles

**Erreur d'authentification SMTP** → Vérifier le mot de passe d'application Gmail

**Quotas non appliqués** → Activer les quotas sur la partition (voir Partie 1)

**Module mail non trouvé** → Installer `mailutils` sur le serveur

**SSH connection failed** → Vérifier l'IP et que vous avez accès SSH root au serveur
