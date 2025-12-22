#!/bin/bash

# Script de création automatisée d'utilisateurs Linux
# Usage: sudo ./create_users.sh <nom_du_groupe> <fichier_users>

set -euo pipefail

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Ce script doit être exécuté en root (sudo)" 
   exit 1
fi

# Vérification des arguments
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <nom_du_groupe> <fichier_users>"
    echo "Exemple: $0 students-inf-361 users.txt"
    exit 1
fi

GROUP_NAME="$1"
USERS_FILE="$2"
LOG_FILE="/tmp/logs/creation_$(date +%Y%m%d_%H%M%S).log"

# Créer le dossier logs
mkdir -p /tmp/logs

# Fonction de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========== DÉBUT DU SCRIPT =========="
log "Groupe cible: $GROUP_NAME"
log "Fichier source: $USERS_FILE"

# Vérifier que le fichier existe
if [[ ! -f "$USERS_FILE" ]]; then
    log "❌ ERREUR: Le fichier $USERS_FILE n'existe pas"
    exit 1
fi

# 1. Créer le groupe students-inf-361
if getent group "$GROUP_NAME" > /dev/null 2>&1; then
    log "ℹ️  Le groupe $GROUP_NAME existe déjà"
else
    groupadd "$GROUP_NAME"
    log "✅ Groupe $GROUP_NAME créé"
fi

# Configurer sudoers pour bloquer 'su' pour le groupe
SUDOERS_FILE="/etc/sudoers.d/${GROUP_NAME}_nosu"
if [[ ! -f "$SUDOERS_FILE" ]]; then
    echo "%${GROUP_NAME} ALL=(ALL:ALL) ALL, !/bin/su, !/usr/bin/su" > "$SUDOERS_FILE"
    chmod 440 "$SUDOERS_FILE"
    log "✅ Restriction 'su' configurée pour $GROUP_NAME"
fi

# Activer les quotas si nécessaire
check_quota() {
    if ! command -v setquota &> /dev/null; then
        log "⚠️  Installation de quota-tools..."
        apt-get update -qq && apt-get install -y quota quotatool > /dev/null 2>&1
        log "✅ quota-tools installé"
    fi
}

check_quota

# Lire le fichier ligne par ligne
while IFS=';' read -r username password fullname phone email shell; do
    
    # Ignorer les lignes vides
    [[ -z "$username" ]] && continue
    
    log "---------- Traitement de l'utilisateur: $username ----------"
    
    # 2. Vérifier si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        log "⚠️  L'utilisateur $username existe déjà, ignoré"
        continue
    fi
    
    # 2c. Vérifier et installer le shell si nécessaire
    if [[ ! -f "$shell" ]]; then
        log "⚠️  Shell $shell non trouvé, tentative d'installation..."
        
        case "$shell" in
            */zsh)
                apt-get install -y zsh > /dev/null 2>&1 && log "✅ zsh installé" || { shell="/bin/bash"; log "❌ Échec installation zsh, utilisation de /bin/bash"; }
                ;;
            */fish)
                apt-get install -y fish > /dev/null 2>&1 && log "✅ fish installé" || { shell="/bin/bash"; log "❌ Échec installation fish, utilisation de /bin/bash"; }
                ;;
            *)
                shell="/bin/bash"
                log "⚠️  Shell inconnu, utilisation de /bin/bash"
                ;;
        esac
    fi
    
    # 2. Créer l'utilisateur avec son répertoire personnel
    useradd -m -s "$shell" -c "$fullname,$phone,$email" -G "$GROUP_NAME,sudo" "$username"
    log "✅ Utilisateur $username créé (shell: $shell)"
    
    # 4. Configurer le mot de passe haché (SHA-512)
    echo "$username:$password" | chpasswd -c SHA512
    log "✅ Mot de passe configuré"
    
    # 5. Forcer le changement de mot de passe à la première connexion
    chage -d 0 "$username"
    log "✅ Changement de mot de passe forcé"
    
    # 7. Message de bienvenue personnalisé
    WELCOME_FILE="/home/$username/WELCOME.txt"
    cat > "$WELCOME_FILE" << EOF
╔════════════════════════════════════════════════════════════╗
║          BIENVENUE SUR LE SERVEUR INF 3611                 ║
╚════════════════════════════════════════════════════════════╝

Bonjour $fullname,

Votre compte a été créé avec succès !

📧 Email: $email
📱 WhatsApp: $phone
👤 Username: $username
🏠 Répertoire: /home/$username

💾 Quota disque: 15 Go maximum
🧠 Limite RAM par processus: 20%

Pour votre sécurité:
- Changez votre mot de passe dès la première connexion
- Utilisez des mots de passe forts
- Ne partagez jamais vos identifiants

════════════════════════════════════════════════════════════
EOF
    
    chown "$username:$username" "$WELCOME_FILE"
    chmod 644 "$WELCOME_FILE"
    
    # Ajouter l'affichage dans .bashrc
    echo "" >> "/home/$username/.bashrc"
    echo "# Message de bienvenue" >> "/home/$username/.bashrc"
    echo "cat ~/WELCOME.txt" >> "/home/$username/.bashrc"
    chown "$username:$username" "/home/$username/.bashrc"
    
    log "✅ Message de bienvenue configuré"
    
    # 8. Configurer quota disque (15 Go)
    setquota -u "$username" 14680064 15728640 0 0 / 2>/dev/null || log "⚠️  Quota non configuré (vérifier si quotas activés sur partition)"
    log "✅ Quota disque configuré: 15 Go"
    
    # 9. Limiter utilisation RAM (20% de la RAM totale)
    TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    RAM_LIMIT=$((TOTAL_RAM * 20 / 100))
    
    LIMITS_FILE="/etc/security/limits.d/${username}_limits.conf"
    cat > "$LIMITS_FILE" << EOF
$username soft rss $RAM_LIMIT
$username hard rss $RAM_LIMIT
$username soft nproc 100
$username hard nproc 150
EOF
    
    log "✅ Limite RAM configurée: ${RAM_LIMIT} KB (~20%)"
    
    log "✅✅✅ Utilisateur $username créé avec succès"
    
done < "$USERS_FILE"

log "========== SCRIPT TERMINÉ AVEC SUCCÈS =========="
log "📊 Log complet disponible: $LOG_FILE"

echo ""
echo "✅ Tous les utilisateurs ont été créés avec succès !"
echo "📄 Consultez le log: $LOG_FILE"
