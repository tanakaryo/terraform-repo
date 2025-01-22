resource "google_cloud_run_service" "hello_container" {
  name = "hello"
  location = var.region
  project = var.project

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
}