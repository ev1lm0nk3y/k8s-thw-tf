resource "random_uuid" "bucket_suffix" {}

resource "google_storage_bucket" "k8s_thw" {
  name = "k8s-thw-${random_uuid.bucket_suffix.result}"
}

data "template_file" "worker_csrs" {
  count    = 3
  template = "files/worker-csr.json.tpl"

  vars = {
    city  = var.city
    state = var.state
  }
}

resource "google_storage_bucket_object" "worker_csrs" {
  count  = 3
  bucket = google_storage_bucket.k8s_thw.name
  name   = "worker-${count.index}"

  content = template_file.worker_csrs.rendered[count.index]
}
