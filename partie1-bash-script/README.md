# Partie 1 : Script Bash

## Utilisation

```bash
chmod +x create_users.sh
sudo ./create_users.sh students-inf-361 users.txt
```

## Format du fichier users.txt

```
username;password;full_name;phone;email;shell
```

Exemple:
```
alice;Pass123!;Alice Dupont;+237690123456;alice@email.com;/bin/bash
bob;SecureP@ss;Bob Martin;+237691234567;bob@email.com;/bin/zsh
```

## Ce qui est implémenté

- Création du groupe passé en paramètre
- Création des users avec leurs infos (nom, tel, mail)
- Vérification et installation du shell demandé (bash par défaut si échec)
- Mot de passe haché en SHA-512
- Changement de mdp forcé à la première connexion
- Ajout au groupe sudo mais blocage de la commande `su`
- Message de bienvenue dans ~/WELCOME.txt affiché au login
- Quota disque 15 Go par user
- Limite RAM 20% par processus
- Logs d'exécution dans `logs/`

## Activer les quotas (important!)

Les quotas disque ne marchent que si activés sur la partition:

```bash
# Éditer /etc/fstab, ajouter usrquota,grpquota
sudo nano /etc/fstab
# Ex: / ext4 defaults,usrquota,grpquota 0 1

sudo mount -o remount /
sudo quotacheck -cum /
sudo quotaon /
```

## Installation des dépendances

```bash
sudo apt-get install quota quotatool
```

## Problèmes courants

**"quota non configuré"** → Vérifier que quotas activés sur la partition (voir ci-dessus)

**"shell non trouvé"** → Le script essaie d'installer zsh/fish automatiquement, sinon met bash

**"permission denied"** → Lancer avec sudo

## Logs

Les logs sont dans `logs/creation_DATE_HEURE.log` avec tous les détails d'exécution.
