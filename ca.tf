data "template_file" "ca_csr" {
  template = "files/ca-csr.json.tpl"

  vars = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_cert_auth" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.ca_csr.rendered} | cfssl gencert -initca - | cfssljson -bare generated/ca"
  }
}

resource "google_storage_bucket_object" "ca" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "ca.pem"
  source = "generated/ca.pem"

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}

resource "google_storage_bucket_object" "ca_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "ca-key.pem"
  source = "generated/ca-key.pem"

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}
