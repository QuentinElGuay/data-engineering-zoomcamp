provider "google" {
  project     = "de-zoomcamp-course-450712"
  region      = "us-central1"
}

resource "google_storage_bucket" "de-zoomcamp" {
  name          = "de-zoomcamp-course-quentin"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}
