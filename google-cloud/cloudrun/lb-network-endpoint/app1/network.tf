resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
    name = "${var.name}-neg"
    network_endpoint_type = "SERVERLESS"
    region = var.region
    cloud_run {
      service = google_cloud_run_service.hello_container.name
    }
}