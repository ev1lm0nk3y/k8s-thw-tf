data "template_file" "kube_scheduler_csr" {
  template = "files/kube-scheduler-csr.json.tpl"

  vars    = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_kube_scheduler_cert" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.kube_scheduler_csr.rendered}\" | cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -profile=kubernetes - | cfssljson -bare generated/kube-scheduler"
  }

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}

resource "google_storage_bucket_object" "kube_scheduler_ca" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kube-scheduler.pem"
  source = "generated/kube-scheduler.pem"

  depends_on = [
    null_resource.generated_kube_scheduler_cert,
  ]
}

resource "google_storage_bucket_object" "kube_scheduler_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kube-scheduler-key.pem"
  source = "generated/kube-scheduler-key.pem"

  depends_on = [
    null_resource.generated_kube_scheduler_cert,
  ]
}
