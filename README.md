# TP Administration Systèmes et Réseaux

**INF 3611 - Automatisation de la création d'utilisateurs Linux**

## Description

Automatisation de la création de comptes utilisateurs sur un VPS Linux avec trois approches: Bash, Ansible et Terraform.

## Structure du projet

```
tp-admin-sys-reseaux/
├── README.md
├── .gitignore
├── partie0-ssh-security/
│   └── README.md
├── partie1-bash-script/
│   ├── README.md
│   ├── create_users.sh
│   ├── users.txt
│   └── logs/
├── partie2-ansible/
│   ├── README.md
│   ├── create_users.yml
│   ├── inventory.ini
│   └── users.csv
└── partie3-terraform/
    ├── README.md
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example
```

## Fonctionnalités implémentées

- Création de groupe d'utilisateurs
- Création automatique d'utilisateurs avec infos complètes
- Installation automatique des shells (bash/zsh/fish)
- Hashage des mots de passe (SHA-512)
- Changement de mot de passe forcé à la première connexion
- Accès sudo avec blocage de la commande `su`
- Message de bienvenue personnalisé
- Quotas disque (15 Go par user)
- Limites RAM (20% par processus)
- Logging détaillé
- Envoi d'emails automatiques (Ansible)
- Infrastructure as Code (Terraform)

## Quick Start

### Partie 1 : Script Bash
```bash
cd partie1-bash-script
chmod +x create_users.sh
sudo ./create_users.sh students-inf-361 users.txt
```

### Partie 2 : Ansible
```bash
cd partie2-ansible
# Modifier inventory.ini et les variables SMTP dans create_users.yml
ansible-playbook -i inventory.ini create_users.yml
```

### Partie 3 : Terraform
```bash
cd partie3-terraform
cp terraform.tfvars.example terraform.tfvars
# Modifier terraform.tfvars avec vos valeurs
terraform init
terraform apply
```

## Prérequis système

```bash
# Pour le script Bash et Ansible
sudo apt install quota quotatool

# Pour Ansible
sudo apt install ansible

# Pour Terraform
# Voir partie3-terraform/README.md
```

## Configuration SSH recommandée

Voir `partie0-ssh-security/README.md` pour:
- Procédure de modification sécurisée du serveur SSH
- Paramètres de sécurité essentiels
- Risques et bonnes pratiques

## Notes importantes

- **Quotas disque**: Nécessitent activation sur la partition (voir partie1)
- **Emails Ansible**: Configurer SMTP avec mot de passe d'application Gmail
- **Terraform**: Ne jamais commit `terraform.tfvars` (contient infos sensibles)
- **Clés SSH**: Configurées pour connexion sans mot de passe

## Auteur

TP réalisé dans le cadre du cours INF 3611 - Administration Systèmes et Réseaux  
Département d'Informatique - Licence 3  
Décembre 2025
