data "template_file" "ca_csr" {
  template = "files/ca-csr.json.tpl"

  vars = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_cert_auth" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.ca_csr.rendered} | cfssl gencert -initca - | cfssljson -bare -stdout"
  }
}

resource "google_storage_bucket_object" "cert_auth" {
  bucket = google_storage_bucket.k8s_thw.name

  name = ""
}
