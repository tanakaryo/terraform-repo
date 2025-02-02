locals {
  vpc = {
    name = "lb-network"
  }
  subnet = {
    name     = "lb-subnet"
    ip_range = "10.1.2.0/24"
  }

  proxy_subnet = {
    name     = "proxy-only-subnet"
    purpose  = "REGIONAL_MANAGED_PROXY"
    role     = "ACTIVE"
    ip_range = "10.129.0.0/23"
  }
}

resource "google_compute_network" "default" {
  name                    = local.vpc.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = local.subnet.name
  ip_cidr_range = local.subnet.ip_range
  region        = lookup(var.project_config, var.region)
  network       = google_compute_network.default.id
}

resource "google_compute_subnetwork" "proxy_subnet" {
  name          = local.proxy_subnet.name
  purpose       = local.proxy_subnet.purpose
  role          = local.proxy_subnet.role
  region        = lookup(var.project_config, var.region)
  ip_cidr_range = local.proxy_subnet.ip_range
  network       = google_compute_network.default.id
}