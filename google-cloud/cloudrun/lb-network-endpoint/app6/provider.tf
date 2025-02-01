terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "6.15.0"
    }
  }
}

provider "google" {
  project = "${lookup(var.project_info, var.project_id)}"
  region = "${lookup(var.project_info, var.region)}"
}