locals {
  vpc_parameter = {
    cidr = "10.0.1.0/24"
  }

  vpc_name = "tcp-proxy-xlb-network"
  subnet_name = "tcp-proxy-xlb-subnet"
}

resource "google_compute_network" "default" {
    name = local.vpc_name
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
    name = local.subnet_name
    ip_cidr_range = local.vpc_parameter.cidr
    region = "${lookup(var.project_info, var.region)}"
    network = google_compute_network.default.id
}