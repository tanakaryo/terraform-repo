locals {
  forwarding_rule = {
    name = "tcp-proxy-xlb-forwarding-rule"
    protocol = "TCP"
    schema = "EXTERNAL"
    port_range = "80"
  }

  tcp_proxy = {
    name = "proxy-health-check"
  }

  backend = {
    name = "proxy-xlb-backend-service"
    protocol = "TCP"
    port_name = "tcp"
    schema = "EXTERNAL"
    timeout_sec = 10
    balancing_mode = "CONNECTION"
  }

  health_check = {
    name = "tcp-proxy-health-check"
    timeout_sec = 1
    check_interval_sec = 1
    target_port = "80"
  }
}

resource "google_compute_global_forwarding_rule" "default" {
    name = local.forwarding_rule.name
    #region = "${lookup(var.project_info, var.region)}"
    ip_protocol = local.forwarding_rule.protocol
    load_balancing_scheme = local.forwarding_rule.schema
    port_range = local.forwarding_rule.port_range
    target = google_compute_target_tcp_proxy.default.id
    ip_address = google_compute_global_address.default.id
}

resource "google_compute_target_tcp_proxy" "default" {
    name = local.tcp_proxy.name
    #region = "${lookup(var.project_info, var.region)}"
    backend_service = google_compute_backend_service.default.id
}

data "google_compute_instance_group" "group1" {
  name = google_compute_instance_group.default.name
  provider = google
  zone = "${lookup(var.project_info, var.region)}-a"
}

resource "google_compute_backend_service" "default" {
  name = local.backend.name
  #region = "${lookup(var.project_info, var.region)}"
  protocol = local.backend.protocol
  port_name = local.backend.port_name
  load_balancing_scheme = local.backend.schema
  timeout_sec = local.backend.timeout_sec
  health_checks = [ google_compute_health_check.default.id ]
  backend {
    group = data.google_compute_instance_group.group1.id
    balancing_mode = local.backend.balancing_mode
    max_connections_per_instance = 1
  }
}

resource "google_compute_health_check" "default" {
    name = local.health_check.name
    #region = "${lookup(var.project_info, var.region)}"
    timeout_sec = local.health_check.timeout_sec
    check_interval_sec = local.health_check.check_interval_sec

    tcp_health_check {
      port = local.health_check.target_port
    }
}