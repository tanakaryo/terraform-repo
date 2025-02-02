terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.15.0"
    }
  }
}

provider "google" {
  project = lookup(var.project_config, var.project_id)
  region  = lookup(var.project_config, var.region)
}