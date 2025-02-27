variable "credentials" {
  description = "The path to your GCP service account credentials."
  default     = "./keys/credentials.json"
}

variable "project_id" {
  description = "The ID of your GCP project"
  default     = "de-zoomcamp-course-450712"
}

variable "location" {
  description = "GCP location"
  default     = "US"
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "nyc_taxi_bucket_name" {
  description = "Name of the bucket hosting the NYC taxi data"
  default     = "de-zoomcamp-course-quentin"
}
