resource "google_compute_backend_service" "service" {
    name = "backend-service"
    port_name = "http"
    protocol = "HTTP"
    enable_cdn = false
    timeout_sec = 10
    health_checks = [ google_compute_health_check.tracking_lb.self_link ]
    backend {
      group = google_compute_instance_group.vm_group.self_link
    }
}

resource "google_compute_url_map" "url_map" {
    name = "url-map"
    default_service = google_compute_backend_service.service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
    name = "http-proxy"
    url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_address" "address" {
  name = "address"
  project = var.project_id
  ip_version = "IPV4"
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
    name = "forwarding-rule"
    target = google_compute_target_http_proxy.http_proxy.id
    port_range = "80"

    ip_address = google_compute_global_address.address.address
    ip_protocol = "TCP"

    depends_on = [ 
        google_compute_target_http_proxy.http_proxy,
        google_compute_global_address.address
     ]
}