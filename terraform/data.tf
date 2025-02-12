data "google_compute_image" "debian_latest" {
  family  = "debian-11"
  project = "debian-cloud"
}

variable "image" {
  description = "Image du disque d'amorçage"
  type        = string
  default     = data.google_compute_image.debian_latest.self_link
}
