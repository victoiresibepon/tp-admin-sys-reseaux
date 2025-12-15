terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

# Connexion SSH au serveur
resource "null_resource" "ssh_connection" {
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    port        = var.ssh_port
  }

  # Copier le script sur le serveur
  provisioner "file" {
    source      = var.script_path
    destination = "/tmp/create_users.sh"
  }

  # Copier le fichier users.txt
  provisioner "file" {
    source      = var.users_file_path
    destination = "/tmp/users.txt"
  }

  # Créer le dossier logs
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/logs"
    ]
  }

  # Rendre le script exécutable et l'exécuter
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_users.sh",
      "/tmp/create_users.sh ${var.group_name} /tmp/users.txt"
    ]
  }

  # Récupérer les logs après exécution
  provisioner "local-exec" {
    command = "scp -P ${var.ssh_port} -i ${var.ssh_private_key_path} ${var.ssh_user}@${var.server_ip}:/tmp/logs/* ./logs/ || true"
  }

  triggers = {
    always_run = timestamp()
  }
}

# Output pour confirmer l'exécution
output "execution_status" {
  value = "Script exécuté avec succès sur ${var.server_ip}"
}

output "log_location" {
  value = "Les logs ont été récupérés dans ./logs/"
}
