locals {
  neg = {
    name = "serverless-neg"
    type = "SERVERLESS"

  }
}

resource "google_compute_region_network_endpoint_group" "default" {
    name = local.neg.name
    network_endpoint_type = local.neg.type
    region = "${lookup(var.project_config, var.region)}"
    cloud_run {
      service = google_cloud_run_service.default.name
    }
}