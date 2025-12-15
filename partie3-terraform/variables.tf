variable "server_ip" {
  description = "Adresse IP du serveur VPS"
  type        = string
}

variable "ssh_user" {
  description = "Utilisateur SSH (généralement root)"
  type        = string
  default     = "root"
}

variable "ssh_port" {
  description = "Port SSH du serveur"
  type        = number
  default     = 22
}

variable "ssh_private_key_path" {
  description = "Chemin vers la clé privée SSH"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "script_path" {
  description = "Chemin vers le script create_users.sh"
  type        = string
  default     = "../partie1-bash-script/create_users.sh"
}

variable "users_file_path" {
  description = "Chemin vers le fichier users.txt"
  type        = string
  default     = "../partie1-bash-script/users.txt"
}

variable "group_name" {
  description = "Nom du groupe à créer"
  type        = string
  default     = "students-inf-361"
}
