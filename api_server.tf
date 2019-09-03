data "template_file" "kube_api_csr" {
  template = "files/kube-api-csr.json.tpl"

  vars    = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_kube_api_cert" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.kube_api_csr.rendered}\" | cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${google_compute_address.k8s_thw_address.address},127.0.0.1,kubernetes.default -profile=kubernetes - | cfssljson -bare generated/kubernetes"
  }

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}

resource "google_storage_bucket_object" "kube_api_ca" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kubernetes.pem"
  source = "generated/kubernetes.pem"

  depends_on = [
    null_resource.generated_kube_api_cert,
  ]
}

resource "google_storage_bucket_object" "kube_api_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kubernetes-key.pem"
  source = "generated/kubernetes-key.pem"

  depends_on = [
    null_resource.generated_kube_api_cert,
  ]
}
