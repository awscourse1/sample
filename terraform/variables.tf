variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "Chemin vers le fichier de clé JSON"
  type        = string
}

variable "instance_name" {
  description = "Nom de l'instance VM"
  type        = string
  default     = "mon-instance-gcp"
}

variable "machine_type" {
  description = "Type de machine GCP"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Image du disque d'amorçage"
  type        = string
  default     = "debian-cloud/debian-11"
}


variable "network_interface" {
  description = "Interface network"
  type        = string
  default     = "default"
}