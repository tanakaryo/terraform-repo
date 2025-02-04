locals {
  bucket_iam = {
    role = "roles/storage.objectViewer"
    member = "allUsers"
  }
}

resource "google_storage_bucket_iam_member" "default" {
    bucket = google_storage_bucket.default.name
    role = local.bucket_iam.role
    member = local.bucket_iam.member
}