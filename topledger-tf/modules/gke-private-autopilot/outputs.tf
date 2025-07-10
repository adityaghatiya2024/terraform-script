# modules/gke-private-autopilot/outputs.tf

output "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  value       = google_container_cluster.private_autopilot_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE Autopilot cluster."
  value       = google_container_cluster.private_autopilot_cluster.endpoint
}

# Corrected: The subnetwork self_link now references the data source for the existing subnetwork
output "gke_subnetwork_self_link" {
  description = "The self_link of the GKE subnetwork."
  value       = data.google_compute_subnetwork.existing_gke_subnetwork.self_link
}
