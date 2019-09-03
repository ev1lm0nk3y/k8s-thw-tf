data "template_file" "admin_csr" {
  template = "files/admin-csr.json.tpl"

  vars    = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_admin_cert" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.admin_csr.rendered} | cfssl gencert -ca=generated/ca.pen -ca-key=generated/ca-key.pem -config=files/ca-config.json -profile=kubernetes - | cfssljson -bare generated/admin"
  }
}

resource "google_storage_bucket_object" "admin" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "admin.pem"
  source = "generated/admin.pem"

  depends_on = [
    null_resource.generate_admin_cert,
  ]
}

resource "google_storage_bucket_object" "admin_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "admin-key.pem"
  source = "generated/admin-key.pem"

  depends_on = [
    null_resource.generate_admin_cert,
  ]
}
