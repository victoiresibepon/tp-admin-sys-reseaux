# Partie 0 : Sécurité du Serveur SSH

## 1. Procédure correcte pour modifier la configuration SSH

### Étapes recommandées :

1. **Sauvegarder le fichier de configuration actuel**
   
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)
   

2. **Ouvrir une session SSH supplémentaire**
   - Garder la connexion actuelle active comme session de secours
   - Ouvrir un nouveau terminal et se connecter au serveur

3. **Modifier le fichier de configuration**
   
   sudo nano /etc/ssh/sshd_config
   # ou
   sudo vim /etc/ssh/sshd_config
   

4. **Tester la validité de la configuration**
   
   sudo sshd -t
   
   Cette commande vérifie la syntaxe sans appliquer les modifications

5. **Recharger le service SSH (pas restart)**
   
   sudo systemctl reload sshd
   # ou
   sudo service ssh reload
   

6. **Tester la connexion depuis la nouvelle session**
   - Vérifier que la connexion fonctionne avec les nouveaux paramètres
   - Ne pas fermer la session originale avant confirmation

7. **Si tout fonctionne, fermer l'ancienne session**
   - En cas de problème, utiliser la session de secours pour corriger

---

## 2. Principal risque encouru

### Risque majeur : Perte d'accès au serveur

Si la procédure n'est pas respectée, notamment si on fait `systemctl restart sshd` au lieu de `reload` ou si on ferme toutes les sessions avant de tester, **on risque de se bloquer définitivement l'accès au serveur**.

**Conséquences :**
- Impossibilité de se reconnecter en SSH
- Sur un VPS distant, obligation d'utiliser la console d'urgence du fournisseur (si disponible)
- Perte de temps et potentiellement nécessité de réinstaller le système
- En production, cela signifie une interruption de service

**Pourquoi `reload` plutôt que `restart` ?**
- `reload` recharge la configuration sans couper les connexions existantes
- `restart` coupe toutes les connexions actives, y compris la vôtre

---

## 3. Cinq paramètres de sécurité essentiels

### 3.1 **PermitRootLogin no**

**Configuration :**
```bash
PermitRootLogin no
```

**Justification :**
- Empêche la connexion directe avec le compte root
- Force l'utilisation d'un compte utilisateur personnel suivi de `sudo`
- Assure la traçabilité des actions (on sait qui fait quoi)
- Réduit considérablement les risques d'attaques par force brute sur le compte root
- Principe de moindre privilège : on se connecte en utilisateur normal et on élève les privilèges seulement quand nécessaire

---

### 3.2 **PasswordAuthentication no**

**Configuration :**
```bash
PasswordAuthentication no
PubkeyAuthentication yes
```

**Justification :**
- Désactive l'authentification par mot de passe
- Force l'utilisation de clés SSH (paire publique/privée)
- Les clés SSH sont cryptographiquement beaucoup plus sûres (généralement 2048 ou 4096 bits)
- Immunise contre les attaques par dictionnaire et force brute sur les mots de passe
- Élimine le risque de mots de passe faibles ou réutilisés

---

### 3.3 **Port 2222** (ou autre port non-standard)

**Configuration :**
```bash
Port 2222
```

**Justification :**
- Change le port d'écoute SSH par défaut (22)
- Réduit drastiquement le nombre d'attaques automatisées par des bots
- Les scanners automatiques ciblent généralement le port 22
- Stratégie de "security through obscurity" complémentaire (pas suffisante seule, mais utile)
- Réduit le bruit dans les logs (moins de tentatives de connexion à analyser)

**Note :** Documenter le nouveau port pour les utilisateurs légitimes

---

### 3.4 **MaxAuthTries 3**

**Configuration :**
```bash
MaxAuthTries 3
LoginGraceTime 30
```

**Justification :**
- Limite le nombre de tentatives d'authentification par connexion à 3
- Réduit l'efficacité des attaques par force brute
- `LoginGraceTime 30` limite à 30 secondes le temps pour s'authentifier
- Après 3 échecs, la connexion est fermée et l'attaquant doit recommencer
- Combiné avec d'autres mesures (fail2ban), cela peut bloquer l'IP après plusieurs tentatives

---

### 3.5 **AllowGroups students-inf-361**

**Configuration :**
```bash
AllowGroups students-inf-361 admin
# ou alternativement
AllowUsers user1 user2 user3
```

**Justification :**
- Restreint l'accès SSH uniquement aux membres de groupes spécifiques
- Principe de liste blanche : seuls les utilisateurs explicitement autorisés peuvent se connecter
- Même si un compte utilisateur existe sur le système, il ne pourra pas se connecter en SSH s'il n'est pas dans un groupe autorisé
- Facilite la gestion des accès : ajouter/retirer un utilisateur du groupe suffit
- Réduit la surface d'attaque en limitant les comptes accessibles à distance

---

## Paramètres supplémentaires recommandés

### Autres paramètres importants à considérer :

```bash
# Désactiver les méthodes d'authentification faibles
Protocol 2

# Désactiver X11 forwarding si non nécessaire
X11Forwarding no

# Désactiver la redirection de port si non nécessaire
AllowTcpForwarding no

# Timeout pour les sessions inactives
ClientAliveInterval 300
ClientAliveCountMax 2

# Désactiver l'authentification par fichier .rhosts
IgnoreRhosts yes
HostbasedAuthentication no

# Ne pas autoriser les mots de passe vides
PermitEmptyPasswords no
```

---

## Commandes utiles

```bash
# Tester la configuration SSH
sudo sshd -t

# Voir la configuration active
sudo sshd -T

# Recharger SSH après modification
sudo systemctl reload sshd

# Voir les tentatives de connexion échouées
sudo grep "Failed password" /var/log/auth.log

# Voir les connexions réussies
sudo grep "Accepted" /var/log/auth.log
```

---

## Outils complémentaires recommandés

- **fail2ban** : Bannir automatiquement les IPs après plusieurs tentatives échouées
- **UFW/iptables** : Configurer un firewall pour filtrer les connexions
- **SSH keys avec passphrase** : Protéger les clés privées
- **Authentification à deux facteurs (2FA)** : Avec Google Authenticator par exemple

---

**Auteur :** SI'BEPON NOUAYE DEBORA VICTOIRE
**Date :** Décembre 2025  
**Cours :** INF 3611 - Administration Systèmes et Réseaux
