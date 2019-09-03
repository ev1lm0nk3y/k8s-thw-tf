terraform {
  backend "local" {
    path = "/home/ryan/git/k8s-thw-tf/tf.state"
  }
}

provider "google" {
  project = "gumshoe-test"
  region  = "us-east4"
}
