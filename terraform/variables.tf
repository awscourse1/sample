variable "project_id" {
  description = "ID du projet"
  type        = string
}

variable "region" {
  description = "Région"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
  description = "Chemin vers le fichier de credentials"
  type        = string
}

variable "instance_name" {
  description = "Nom de l'instance"
  type        = string
  default     = "mon-instance-gcp"
}

variable "machine_type" {
  description = "Type de machine"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "Zone"
  type        = string
  default     = "us-central1-a"
}

variable "image" {
  description = "Image"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "network" {
  description = "Réseau"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags"
  type        = list(string)
  default     = ["web"]
}
