resource "google_compute_network" "lb_network" {
    name = "${var.name}-lb-networ"
    project = var.project_id
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lb_subnet" {
    name = "${var.name}-lb-subnet"
    project = var.project_id
    ip_cidr_range = "10.0.1.0/24"
    region = var.region
    network = google_compute_network.lb_network.id
}