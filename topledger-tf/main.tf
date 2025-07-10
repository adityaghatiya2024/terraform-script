# main.tf (Root Module)

# Configure Terraform to use GCS for remote state and state locking
terraform {
  backend "gcs" {
    bucket = "tl-terraform-state-bucket" # <--- IMPORTANT: Replace with your GCS bucket name
    prefix = "gke-autopilot-cluster"             # Optional: A path within the bucket for this state
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Define variables for the root module, which will be sourced from terraform.tfvars
variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "The Google Cloud region where the cluster will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  type        = string
}

# New variables for existing network details - THESE MUST BE DECLARED HERE
variable "existing_network_name" {
  description = "The name of the existing VPC network."
  type        = string
}

variable "existing_subnetwork_name" {
  description = "The name of the existing subnetwork."
  type        = string
}

variable "existing_pods_secondary_range_name" {
  description = "The name of the existing secondary IP range for GKE pods."
  type        = string
}

variable "existing_services_secondary_range_name" {
  description = "The name of the existing secondary IP range for GKE services."
  type        = string
}

variable "control_plane_cidr_block" {
  description = "The CIDR block for the GKE control plane's internal IP."
  type        = string
}

variable "master_authorized_networks_cidr" {
  description = "CIDR block for master authorized networks to access the control plane."
  type        = string
}

variable "node_disk_size_gb" { # This variable is no longer used by the GKE module for Autopilot, but kept for consistency with tfvars
  description = "The disk size in GB for each node in the default node pool."
  type        = number
}

variable "min_node_count" { # This variable is no longer used by the GKE module for Autopilot, but kept for consistency with tfvars
  description = "The minimum number of nodes for the Autopilot cluster."
  type        = number
}

variable "max_node_count" { # This variable is no longer used by the GKE module for Autopilot, but kept for consistency with tfvars
  description = "The maximum number of nodes for the Autopilot cluster."
  type        = number
}

# Call the GKE Autopilot module
module "gke_private_autopilot" {
  source = "./modules/gke-private-autopilot" # Path to your child module

  # Pass variables from the root module to the child module
  project_id                      = var.project_id
  region                          = var.region
  cluster_name                    = var.cluster_name
  existing_network_name           = var.existing_network_name
  existing_subnetwork_name        = var.existing_subnetwork_name
  existing_pods_secondary_range_name = var.existing_pods_secondary_range_name
  existing_services_secondary_range_name = var.existing_services_secondary_range_name
  control_plane_cidr_block        = var.control_plane_cidr_block
  master_authorized_networks_cidr = var.master_authorized_networks_cidr
  # Note: node_disk_size_gb, min_node_count, max_node_count are not passed to the module
  # because they are not used in Autopilot GKE cluster configuration.
}

# Output relevant information from the child module
output "cluster_name" {
  description = "The name of the GKE Autopilot cluster."
  value       = module.gke_private_autopilot.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE Autopilot cluster."
  value       = module.gke_private_autopilot.cluster_endpoint
}

# The subnetwork self_link will now be an output from a data source, not a created resource
output "gke_subnetwork_self_link" {
  description = "The self_link of the GKE subnetwork."
  value       = module.gke_private_autopilot.gke_subnetwork_self_link
}
