variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
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
  description = "Nom de l'instance"
  type        = string
  default     = "mon-instance-gcp"
}

variable "machine_type" {
  description = "Type de machine"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Image du système d'exploitation"
  type        = string
  default     = "debian-cloud/debian-11"
}
