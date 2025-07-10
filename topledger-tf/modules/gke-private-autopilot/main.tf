# modules/gke-private-autopilot/main.tf

# Data source to reference the existing VPC network
data "google_compute_network" "existing_vpc_network" {
  name = var.existing_network_name
}

# Data source to reference the existing subnetwork
data "google_compute_subnetwork" "existing_gke_subnetwork" {
  name    = var.existing_subnetwork_name
  project = var.project_id
  region  = var.region
}

# Enable the Service Networking API for private service access
resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false # Keep the API enabled if the project is not destroyed
}

# Create a private connection for the GKE control plane
# This allocates an IP range for the GKE control plane within your existing VPC
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.cluster_name}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16 # Adjust prefix length as needed for your network
  network       = data.google_compute_network.existing_vpc_network.id # Reference existing network
  # Ensure Service Networking API is enabled before allocating address
  depends_on = [google_project_service.servicenetworking]
}

resource "google_service_networking_connection" "gke_private_connection" {
  network                 = data.google_compute_network.existing_vpc_network.id # Reference existing network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  # Ensure the Service Networking API is enabled before creating the connection
  depends_on = [google_project_service.servicenetworking]
}

# Deploy the GKE Autopilot cluster
resource "google_container_cluster" "private_autopilot_cluster" {
  name     = var.cluster_name
  location = var.region

  # Ensure private connection is established before cluster creation
  depends_on = [google_service_networking_connection.gke_private_connection]

  # Enable Autopilot mode
  enable_autopilot = true

  # Configure private cluster settings
  private_cluster_config {
    enable_private_nodes    = true # Nodes will only have private IP addresses
    enable_private_endpoint = true # Control plane will only be accessible via private IP
    # This CIDR block is for the control plane's internal IP.
    # It must not overlap with your VPC network's CIDR ranges.
    master_ipv4_cidr_block = var.control_plane_cidr_block
  }

  # Add master authorized networks configuration
  master_authorized_networks_config {
    # Removed 'enabled = true' as it's not a valid attribute here.
    # The presence of this block itself implies enablement.
    cidr_blocks {
      display_name = "Authorized Network for Control Plane"
      cidr_block   = var.master_authorized_networks_cidr # Your bastion host subnet
    }
  }

  # IP allocation policy using secondary ranges from the existing subnetwork
  ip_allocation_policy {
    cluster_secondary_range_name  = var.existing_pods_secondary_range_name
    services_secondary_range_name = var.existing_services_secondary_range_name
  }

  # Specify the existing network and subnetwork for the cluster
  network    = data.google_compute_network.existing_vpc_network.name
  subnetwork = data.google_compute_subnetwork.existing_gke_subnetwork.name

  # Set the release channel for the latest stable features
  release_channel {
    channel = "REGULAR" # You can also use "STABLE" or "RAPID"
  }

  # IMPORTANT: In GKE Autopilot, you cannot define 'default_node_pool' or configure
  # specific node properties like disk_size_gb or min/max_node_count directly here.
  # Autopilot automatically manages the node pool and its scaling based on your workloads.
  # If you need specific disk sizes, you typically request them via PersistentVolumeClaims.
  # Cluster autoscaling limits for Autopilot are managed differently and are not
  # set via min_node_count/max_node_count on a default_node_pool.

  # Enable logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # Prevent recreation of the cluster if the name changes
  lifecycle {
    ignore_changes = [
      # Autopilot manages node count dynamically, so ignore changes to prevent recreation.
      # This line is kept for robustness, though default_node_pool is removed.
      # It might be relevant if other node pool related attributes were to be added in the future.
      # For pure Autopilot, this specific ignore_changes might become less critical.
    ]
  }
}
