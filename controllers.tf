resource "google_compute_instance" "controllers" {
  count        = 3
  name         = "controller-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "us-east1-c"

  can_ip_forward = true

  network_interface {
    network_ip = "10.240.0.1${count.index}"
    subnetwork = google_compute_subnetwork.k8s_thw.name
  }

  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  metadata_startup_script = "gsutil cp ${google_storage_bucket.k8s_thw.name}/generated/{ca,ca-key,kubernetes,kubernetes-key,service-account,service-account-key}.pem ${HOME}"

  tags = [
    "k8s-thw",
    "controller",
  ]

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write,monitoring",
    ]
  }
}

data "template_file" "controller_csr" {
  template = "files/controller-manager-csr.json.tpl"

  vars = {
    city  = var.city
    state = var.state
  }
}

resource "null_resource" "generate_controller_cert" {
  provisioner "local-exec" {
    command = "echo \"${data.template_file.controller_csr.rendered}\"| cfssl gencert -ca=generated/ca.pem -ca-key=generated/ca-key.pem -config=files/ca-config.json -profile=kubernetes - | cfssljson -bare generated/kube-controller-manager"
  }

  depends_on = [
    null_resource.generate_cert_auth,
  ]
}

resource "google_storage_bucket_object" "kcm" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kube-controller-manager.pem"
  source = "generated/kube-controller-manager.pem"

  depends_on = [
    null_resource.generate_controller_cert,
  ]
}

resource "google_storage_bucket_object" "kcm_key" {
  bucket = google_storage_bucket.k8s_thw.name

  name   = "kube-controller-manager-key.pem"
  source = "generated/kube-controller-manager.pem"

  depends_on = [
    null_resource.generate_controller_cert,
  ]
}
