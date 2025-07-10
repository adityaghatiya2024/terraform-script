# modules/gke-private-autopilot/variables.tf

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

# Variables for existing network details (replacing old CIDR ranges)
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

# These variables are defined but not directly used in the Autopilot cluster configuration
# as Autopilot manages node properties automatically. They are kept for consistency with tfvars.
variable "node_disk_size_gb" {
  description = "The disk size in GB for each node in the default node pool (not directly used by Autopilot)."
  type        = number
  default     = 128
}

variable "min_node_count" {
  description = "The minimum number of nodes for the Autopilot cluster (not directly used by Autopilot)."
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "The maximum number of nodes for the Autopilot cluster (not directly used by Autopilot)."
  type        = number
  default     = 10
}
