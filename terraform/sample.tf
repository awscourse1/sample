provider "google" {
  project     = "votre-projet-gcp"
  region      = "us-central1"
  credentials = file("chemin-vers-votre-fichier-de-cle.json")
}

resource "google_compute_instance" "vm_instance" {
  name         = "mon-instance-gcp"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Permet une IP publique
    }
  }

  metadata_startup_script = <<EOT
    #!/bin/bash
    apt update && apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOT

  tags = ["web"]
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}