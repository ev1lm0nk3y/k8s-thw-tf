data "template_file" "service_account_csr" {
  template = "files/service-account-csr.json.tpl"

  vars = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_service_account_cert" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.service_account_csr.rendered}\" | cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -profile=kubernetes - | cfssljson -bare generated/service-account"
  }

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}

resource "google_storage_bucket_object" "service_account_ca" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "service-account.pem"
  source = "generated/service-account.pem"

  depends_on = [
    null_resource.generated_service_account_cert,
  ]
}

resource "google_storage_bucket_object" "service_account_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "service-account-key.pem"
  source = "generated/service-account-key.pem"

  depends_on = [
    null_resource.generated_service_account_cert,
  ]
}
