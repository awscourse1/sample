output "instance_ip" {
  description = "Adresse IP publique de l'instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  description = "Nom de l'instance créée"
  value       = google_compute_instance.vm_instance.name
}