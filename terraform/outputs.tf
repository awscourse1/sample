# outputs.tf
output "instance_ip" {
  description = "Adresse IP publique de l'instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
