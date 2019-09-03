resource "random_uuid" "bucket_suffix" {}

resource "google_storage_bucket" "k8s_thw" {
  name = "k8s-thw-${random_uuid.bucket_suffix.result}"
}


