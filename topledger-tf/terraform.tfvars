# terraform.tfvars
# All configurable variables for your GKE Autopilot cluster

project_id      = "tl-gcp-464011" # <--- IMPORTANT: Replace with your actual GCP Project ID
region          = "us-east1"         # <--- IMPORTANT: Choose your desired GCP region
cluster_name    = "tl-private-gke-autopilot-cluster"

# --- Existing Network Details ---
# IMPORTANT: Replace these with the actual names of your existing VPC network, subnetwork,
# and their secondary IP ranges for GKE pods and services.
existing_network_name             = "gcp-topledger-prod-vpc"
existing_subnetwork_name          = "gcp-topledger-prod-gke-subnet"
existing_pods_secondary_range_name = "gke-pods-range" # e.g., "gke-pods"
existing_services_secondary_range_name = "gke-services-range" # e.g., "gke-services"
# --------------------------------

control_plane_cidr_block = "172.16.0.0/28" # Ensure this doesn't overlap with your VPC CIDR

# IMPORTANT: Replace "YOUR_SECURE_PUBLIC_IP/32" with your actual IP or VPN IP.
# Example: "203.0.113.45/32" for a single IP, or "192.168.1.0/24" for a network.
master_authorized_networks_cidr = "10.3.0.0/25" # Your bastion host subnet

# Note: node_disk_size_gb, min_node_count, max_node_count are not directly used by Autopilot GKE module,
# but kept here for consistency if you wish to use them for other purposes or future non-Autopilot clusters.
node_disk_size_gb = 128
min_node_count  = 2
max_node_count  = 10
