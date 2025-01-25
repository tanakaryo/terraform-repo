resource "google_compute_address" "network_lb_ipv4" {
    name = "network-lb-ipv4"
    region = var.region
}

resource "google_compute_region_health_check" "tcp_health_check" {
    name = "tcp-health-check"
    timeout_sec = 1
    check_interval_sec = 1
    region = var.region

    tcp_health_check {
      port = 80
    }
}

resource "google_compute_region_backend_service" "network_lb_backend_service" {
    name = "network-lb-backend-service"
    load_balancing_scheme = "EXTERNAL"
    protocol = "TCP"
    region = var.region
    health_checks = [ google_compute_region_health_check.tcp_health_check.self_link ]

    backend {
      group = google_compute_instance_group.web_server_group.id
      balancing_mode = "CONNECTION"
    }
}

resource "google_compute_forwarding_rule" "network_lb_forwarding_rule_ipv4" {
    name = "network-lb-forwarding-rule-ipv4"
    load_balancing_scheme = "EXTERNAL"
    region = var.region
    port_range = "80"
    ip_address = google_compute_address.network_lb_ipv4.address
    backend_service = google_compute_region_backend_service.network_lb_backend_service.id
}