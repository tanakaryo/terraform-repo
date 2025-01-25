resource "google_compute_network" "lb_network" {
    project = var.project_id
    name = "lb-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lb_subnet" {
    project = var.project_id
    name = "lb-subnet"
    region = var.region
    ip_cidr_range = "10.0.1.0/24"
    network = google_compute_network.lb_network.id
}