locals {
  backend = {
    name = "lb-backend-service"
    schema = "EXTERNAL_MANAGED"
    protocol = "HTTP"
    mode = "UTILIZATION"
    scaler = 1.0
    timeout_sec = 10
  }

  url_map = {
    name = "service-url-map"
  }

  http_proxy = {
    name = "http-proxy"
  }

  forward_rule = {
    name = "http-forwarding-rule"
    schema = "EXTERNAL_MANAGED"
    tier = "STANDARD"
    port_range = "80"
  }
}

resource "google_compute_region_backend_service" "default" {
    name = local.backend.name
    load_balancing_scheme = local.backend.schema
    protocol = local.backend.protocol
    region = "${lookup(var.project_config, var.region)}"
    
    backend {
      group = google_compute_region_network_endpoint_group.default.id
      balancing_mode = local.backend.mode
      capacity_scaler = local.backend.scaler
    }
}

resource "google_compute_region_url_map" "default" {
    name = local.url_map.name
    default_service = google_compute_region_backend_service.default.id
    region = "${lookup(var.project_config, var.region)}"
}

resource "google_compute_region_target_http_proxy" "default" {
    name = local.http_proxy.name
    url_map = google_compute_region_url_map.default.id
    region = "${lookup(var.project_config, var.region)}"
}

resource "google_compute_forwarding_rule" "default" {
    name = local.forward_rule.name
    region = "${lookup(var.project_config, var.region)}"
    load_balancing_scheme = local.forward_rule.schema
    network_tier = local.forward_rule.tier
    target = google_compute_region_target_http_proxy.default.id
    network = google_compute_network.default.id
    ip_address = google_compute_address.default.id
    port_range = local.forward_rule.port_range

    depends_on = [ google_compute_subnetwork.proxy_subnet ]
}