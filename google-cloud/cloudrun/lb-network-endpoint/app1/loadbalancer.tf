resource "google_compute_backend_service" "backend_service" {
    name = "${var.name}-backend"
    protocol = "HTTP"
    port_name = "http"
    timeout_sec = 30

    backend {
        group = google_compute_region_network_endpoint_group.cloudrun_neg.id
    }
}

resource "google_compute_url_map" "url_map" {
    name = "${var.name}-urlmap"
    default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_https_proxy" "target_proxy" {
    name = "${var.name}-https-proxy"

    url_map = google_compute_url_map.url_map.id
    ssl_certificates = [
        google_compute_managed_ssl_certificate.ssl_certs.id
    ]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
    name = "${var.name}-lb"

    target = google_compute_target_https_proxy.target_proxy.id
    port_range = "443"
    ip_address = google_compute_global_address.global_address.address
}