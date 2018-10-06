variable "token" {}
variable "hosts" {
  default = 3
}

provider "hcloud" {
  token = "${var.token}"
}

module "provider" {
  source = "git::https://github.com/suquant/tf_hcloud.git?ref=v1.1.0"

  count = "${var.hosts}"
}

module "wireguard" {
  source = ".."

  count         = "${var.hosts}"
  connections   = "${module.provider.public_ips}"
  private_ips   = "${module.provider.private_ips}"
  overlay_cidr  = "10.10.10.0/24"
}