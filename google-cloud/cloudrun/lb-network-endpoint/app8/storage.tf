locals {
  bucket = {
    name = "cdn-bucket"
    uniform_bucket_level_access = true
    class = "STANDARD"
    destroy = true
    main_page = "index.html"
    not_found_page = "404.html"
  }

  bucket_object_index = {
    name = "index.html"
    content = <<-EOT
      <html><body>
        <h1>Congratulations on setting up Google Cloud CDN with Storage backend!</h1>
      </body></html>
    EOT
  }

  bucket_object_404 = {
    name = "404.html"
    content = <<-EOT
      <html><body>
        <h1>Error: Object you are looking for is no longer available!</h1>
      </html></body>
    EOT
  }
}

resource "random_id" "prefix" {
    byte_length = 8
}

resource "google_storage_bucket" "default" {
    name = "${random_id.prefix.hex}-${local.bucket.name}"
    location = "${lookup(var.project_config, var.region)}"
    uniform_bucket_level_access = local.bucket.uniform_bucket_level_access
    storage_class = local.bucket.class
    force_destroy = local.bucket.destroy
    website {
      main_page_suffix = local.bucket.main_page
      not_found_page = local.bucket.not_found_page
    }
}

resource "google_storage_bucket_object" "index" {
    name = local.bucket_object_index.name
    bucket = google_storage_bucket.default.name
    content = local.bucket_object_index.content
}

resource "google_storage_bucket_object" "error" {
    name = local.bucket_object_404.name
    bucket = google_storage_bucket.default.name
    content = local.bucket_object_404.content
}

resource "google_storage_bucket_object" "test" {
    name = "test-object"

    content = "Data as string to be uploaded"
    content_type = "text/plain"

    bucket = google_storage_bucket.default.name
}