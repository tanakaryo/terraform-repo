locals {
  cloud_run = {
    name = "hello-service"
    image = "gcr.io/cloudrun/hello"
    users = "allUsers"
    percent = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "default" {
    name = local.cloud_run.name
    location = "${lookup(var.project_config, var.region)}"

    template {
      spec {
        containers {
          image = local.cloud_run.image
        }
      }
    }

    traffic {
      percent = local.cloud_run.percent
      latest_revision = local.cloud_run.latest_revision
    }
}

data "google_iam_policy" "noauth" {
    binding {
      role = "roles/run.invoker"
      members = [ 
        "allUsers",
       ]
    }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
    location = "${lookup(var.project_config, var.region)}"
    project = "${lookup(var.project_config, var.project_id)}"
    service = google_cloud_run_service.default.name
    policy_data = data.google_iam_policy.noauth.policy_data
}