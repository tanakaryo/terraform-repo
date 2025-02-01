locals {
  web_server = {
    name = "tcp-proxy-xlb-web-server"
    machine_type = "e2-micro"
    target_tag = ["allow-health-check"]
    image = "debian-cloud/debian-12"
    size = "10"
  }

  server_group = {
    name = "tcp-proxy-xlb-server-group"
    named_port_name = "tcp"
    named_port_number = "80"
  }

  firewall = {
    name = "tcp-proxy-xlb-fw-allow-hc"
    direction = "INGRESS"
    source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
    allow_protocol = "tcp"
    target_tag = ["allow-health-check"]
  }
}

resource "google_compute_instance" "default" {
    name = local.web_server.name
    machine_type = local.web_server.machine_type
    zone = "${lookup(var.project_info, var.region)}-a"

    tags = local.web_server.target_tag

    boot_disk {
      initialize_params {
        image = local.web_server.image
        size = local.web_server.size
      }
    }

    network_interface {
      network = google_compute_network.default.id
      subnetwork = google_compute_subnetwork.default.id
      access_config {
      }
    }

    metadata_startup_script = "sudo apt update; sudo apt install nginx -y; sudo systemctl start nginx"
}

resource "google_compute_instance_group" "default" {
    name = local.server_group.name
    zone = "${lookup(var.project_info,var.region)}-a"

    instances = [ google_compute_instance.default.self_link ]

    named_port {
      name = local.server_group.named_port_name
      port = local.server_group.named_port_number
    }
}

resource "google_compute_firewall" "default" {
    name = local.firewall.name
    direction = local.firewall.direction
    network = google_compute_network.default.id
    source_ranges = local.firewall.source_ranges
    allow {
      protocol = local.firewall.allow_protocol
    }

    target_tags = local.firewall.target_tag
}