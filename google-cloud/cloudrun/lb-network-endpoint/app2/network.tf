resource "google_compute_network" "lb_network" {
    name = "${var.name}-lb-network"
    auto_create_subnetworks = false
}

# Proxy only Subnet
resource "google_compute_subnetwork" "lb_proxy_subnet" {
    name = "${var.name}-lb-proxy-subnet"
    ip_cidr_range = "10.0.0.0/24"
    region = var.region
    purpose = "REGIONAL_MANAGED_PROXY"
    role = "ACTIVE"
    network = google_compute_network.lb_network.id
}

#Backend Subnet
resource "google_compute_subnetwork" "lb_subnet" {
    name = "${var.name}-lb-subnet"
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.lb_network.id
}