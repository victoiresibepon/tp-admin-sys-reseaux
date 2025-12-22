#!/bin/bash

# Script de test complet pour TP Admin Sys & Réseaux
# À exécuter depuis le dossier racine du TP cloné

echo "=============================="
echo "Début des tests du TP"
echo "=============================="

# Partie 0 - SSH Security
echo -e "\n[PARTIE 0] Test SSH"
ssh_version=$(ssh -V 2>&1)
echo "Version SSH : $ssh_version"

echo "Test de connexion SSH vers localhost..."
ssh -o BatchMode=yes -o ConnectTimeout=5 localhost exit
if [ $? -eq 0 ]; then
    echo "Connexion SSH réussie"
else
    echo "Attention : impossible de se connecter à localhost via SSH"
fi

# Partie 1 - Bash Script
echo -e "\n[PARTIE 1] Test Bash Script"
cd partie1-bash-script || exit
chmod +x create_users.sh
echo "Exécution du script create_users.sh..."
sudo ./create_users.sh

echo "Vérification des utilisateurs créés..."
while read user; do
    if getent passwd "$user" > /dev/null; then
        echo "Utilisateur $user créé ✔"
    else
        echo "Utilisateur $user absent ❌"
    fi
done < users.txt

echo "Contenu des logs générés :"
ls logs/

cd ..

# Partie 2 - Ansible
echo -e "\n[PARTIE 2] Test Ansible"
cd partie2-ansible || exit
echo "Exécution du playbook create_users.yml..."
ansible-playbook -i inventory.ini create_users.yml

echo "Vérification des utilisateurs Ansible..."
while IFS=, read -r user _; do
    if getent passwd "$user" > /dev/null; then
        echo "Utilisateur $user créé via Ansible ✔"
    else
        echo "Utilisateur $user absent ❌"
    fi
done < users.csv

cd ..

# Partie 3 - Terraform
echo -e "\n[PARTIE 3] Test Terraform"
cd partie3-terraform || exit
echo "Initialisation Terraform..."
terraform init -input=false

echo "Validation Terraform..."
terraform validate

echo "Application Terraform (confirmer si demandé)..."
terraform apply -auto-approve

echo "Affichage des ressources créées par Terraform..."
terraform show

cd ..

echo -e "\n=============================="
echo "Tests terminés !"
echo "=============================="
