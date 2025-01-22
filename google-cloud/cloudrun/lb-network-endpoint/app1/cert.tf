resource "google_compute_managed_ssl_certificate" "ssl_certs" {
  provider = google

  name = "${var.name}-cert"
  managed {
    domains = ["${var.domain}"]
  }
}