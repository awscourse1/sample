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
    network = var.network
    access_config {
      // Permet une IP publique
    }
  }

  metadata_startup_script = data.local_file.startup_script.content

  tags = var.tags
}
