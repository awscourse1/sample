provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_file)
}

resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {}
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
  description = "Adresse IP publique de l'instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
