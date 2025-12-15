# Partie 3 : Terraform

## Description

Utilisation de Terraform pour exécuter le script Bash de création d'utilisateurs sur le VPS distant.

## Fichiers

- `main.tf` - Configuration principale
- `variables.tf` - Définition des variables
- `terraform.tfvars.example` - Exemple de configuration
- `.gitignore` - Fichiers à ne pas versionner

## Installation de Terraform

### Ubuntu/Debian
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Vérifier l'installation
```bash
terraform --version
```

## Configuration

### 1. Créer votre fichier de variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Remplir avec vos vraies valeurs:
```hcl
server_ip              = "VOTRE_IP"
ssh_user               = "root"
ssh_port               = 22
ssh_private_key_path   = "~/.ssh/id_rsa"
```

### 2. Vérifier que vous avez accès SSH

```bash
ssh -i ~/.ssh/id_rsa root@VOTRE_IP
```

## Utilisation

```bash
# Initialiser Terraform (première fois)
terraform init

# Voir ce qui va être fait
terraform plan

# Exécuter
terraform apply

# Confirmer avec "yes"
```

## Ce que fait Terraform

1. Se connecte au VPS en SSH
2. Copie le script `create_users.sh` dans `/tmp/`
3. Copie le fichier `users.txt` dans `/tmp/`
4. Rend le script exécutable
5. Exécute le script avec le nom du groupe
6. Récupère les logs en local dans `./logs/`

## Commandes utiles

```bash
# Voir les outputs
terraform output

# Détruire (ne détruit pas les users créés, juste l'état Terraform)
terraform destroy

# Reformater les fichiers .tf
terraform fmt

# Valider la config
terraform validate
```

## Notes

- Le fichier `terraform.tfvars` contient des infos sensibles (IP, chemins), **ne jamais le commit sur Git**
- C'est pour ça qu'il est dans `.gitignore`
- On commit seulement `terraform.tfvars.example` comme template

## Problèmes possibles

**Permission denied (publickey)** → Vérifier que votre clé SSH est bien configurée

**Connection timeout** → Vérifier l'IP et que le firewall autorise SSH

**Script not found** → Vérifier les chemins dans `terraform.tfvars`
