locals {
  name = "tpc-proxy-xlb-ip"
}

resource "google_compute_global_address" "default" {
    name = local.name
    #region = "${lookup(var.project_info, var.region)}"
}