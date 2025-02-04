locals {
  forwarding_rule = {
    name = "http-lb-f-rule"
    protocol = "TCP"
    schema = "EXTERNAL"
    port_range = "80"
  }

  http_proxy = {
    name = "http-lb-proxy"
  }

  url_map = {
    name = "http-lb"
  }

  backend_bucket = {
    name = "backend-bucket"
    enable_cdn = true
    cdn_policy = {
        cache_mode = "CACHE_ALL_STATIC"
        client_ttl = 3600
        default_ttl = 3600
        max_ttl = 86400
        negative_caching = true
        serve_while_stable = 86400
    }
  }
}

resource "google_compute_global_forwarding_rule" "default" {
    name = local.forwarding_rule.name
    ip_protocol = local.forwarding_rule.protocol
    load_balancing_scheme = local.forwarding_rule.schema
    port_range = local.forwarding_rule.port_range
    target = google_compute_target_http_proxy.default.id
    ip_address = google_compute_global_address.default.id
}

resource "google_compute_target_http_proxy" "default" {
    name = local.http_proxy.name
    url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
    name = local.url_map.name
    default_service = google_compute_backend_bucket.default.id
}


resource "google_compute_backend_bucket" "default" {
    name = local.backend_bucket.name
    bucket_name = google_storage_bucket.default.name
    enable_cdn = local.backend_bucket.enable_cdn
    cdn_policy {
        cache_mode = local.backend_bucket.cdn_policy.cache_mode
        client_ttl = local.backend_bucket.cdn_policy.client_ttl
        default_ttl = local.backend_bucket.cdn_policy.default_ttl
        max_ttl = local.backend_bucket.cdn_policy.max_ttl
        negative_caching = local.backend_bucket.cdn_policy.negative_caching
        serve_while_stale = local.backend_bucket.cdn_policy.serve_while_stable
    }
}