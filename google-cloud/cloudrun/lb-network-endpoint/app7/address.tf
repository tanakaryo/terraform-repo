locals {
  ip_address = {
    name = "lb-ip-address"
    network_tier="STANDARD"
  }
}

resource "google_compute_address" "default" {
    name = local.ip_address.name
    network_tier = local.ip_address.network_tier
    region = "${lookup(var.project_config, var.region)}"
}