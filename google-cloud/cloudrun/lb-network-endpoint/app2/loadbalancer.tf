resource "google_compute_forwarding_rule" "forwarding_rule" {
    name = "${var.name}-forwarding-rule"
    region = var.region
    depends_on = [ google_compute_subnetwork.lb_proxy_subnet ]
    ip_protocol = "TCP"
    load_balancing_scheme = "INTERNAL_MANAGED"
    port_range = "80"
    target = google_compute_region_target_http_proxy.http_proxy.id
    subnetwork = google_compute_subnetwork.lb_subnet.id
    network_tier = "PREMIUM"
}

# HTTP target proxy
resource "google_compute_region_target_http_proxy" "http_proxy" {
    name = "${var.name}-http-proxy"
    region = var.region
    url_map = google_compute_region_url_map.url_map.id
}

#URL map
resource "google_compute_region_url_map" "url_map" {
    name = "${var.name}-url-map"
    region = var.region
    default_service = google_compute_region_backend_service.backend_service.id
}

# backend service
resource "google_compute_region_backend_service" "backend_service" {
    name = "${var.name}-backend-service"
    region = var.region
    protocol = "HTTP"
    load_balancing_scheme = "INTERNAL_MANAGED"
    timeout_sec = 10
    health_checks = [ google_compute_region_health_check.health_check.id ]
    backend {
      group = google_compute_region_instance_group_manager.mig.instance_group
      balancing_mode = "UTILIZATION"
      capacity_scaler = 1.0
    }
}

resource "google_compute_instance_template" "instance_template" {
    name = "${var.name}-instance-template"
    machine_type = "e2-small"
    tags = [ "http-server" ]

    network_interface {
      network = google_compute_network.lb_network.id
      subnetwork = google_compute_subnetwork.lb_subnet.id
      access_config {
      }
    }

    disk {
      source_image = "debian-cloud/debian-12"
      auto_delete = true
      boot = true
    }

    metadata = {
      startup-script = <<-EOF1
       #! /bin/bash
       set -euo pipefail

       export DEBIAN_FRONTEND=noninteractive
       apt-get update
       apt-get install -y nginx-light jq

       NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
       IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
       METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

       cat <<EOF > /var/www/html/index.html
       <pre>
       Name: $NAME
       IP: $IP
       Metadata: $METADATA
       </pre>
       EOF
      EOF1
    }

    lifecycle {
      create_before_destroy = true
    }
}

resource "google_compute_region_health_check" "health_check" {
    name = "${var.name}-health-check"
    region = var.region
    http_health_check {
      port_specification = "USE_SERVING_PORT"
    }
}

# managed Instance group
resource "google_compute_region_instance_group_manager" "mig" {
    name = "${var.name}-mig"
    region = var.region
    version {
      instance_template = google_compute_instance_template.instance_template.id
      name = "primary"
    }
    base_instance_name = "vm"
    target_size = 2
}

# allow all access from IAP and health check ranges
resource "google_compute_firewall" "fw_iap" {
    name = "${var.name}-fw-iap"
    direction = "INGRESS"
    network = google_compute_network.lb_network.id
    source_ranges = [ "130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20" ]
    allow {
      protocol = "tcp"
    }
}

# allow http from proxy subnet to backends
resource "google_compute_firewall" "fw_lb_to_backend" {
    name = "${var.name}-fw-lb-to-backend"
    direction = "INGRESS"
    network = google_compute_network.lb_network.id
    source_ranges = [ "10.0.0.0/24" ]
    target_tags = [ "http-server" ]
    allow {
      protocol = "tcp"
      ports = [ "80", "443", "8080" ]
    }
}

# test instance
resource "google_compute_instance" "test_vm" {
    name = "${var.name}-test-vm"
    zone = "${var.region}-b"
    machine_type = "e2-small"
    network_interface {
      network = google_compute_network.lb_network.id
      subnetwork = google_compute_subnetwork.lb_subnet.id
    }
    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-12"
      }
    }
}