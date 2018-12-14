# Set the variable value in *.tfvars file
# or using -var="hcloud_token=..." CLI option
variable "hcloud_token" {}
variable "count" {
  default = "3"
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

# Create a server
resource "hcloud_server" "web" {
  count       = "${var.count}"
  name        = "${format("%s-%02d", "web", count.index + 1)}"
  image       = "ubuntu-16.04"
  server_type = "cx11"
  ssh_keys    = ["dev"]
}

module "wireguard" {
  source = "../.."

  count         = "${var.count}"
  connections   = "${hcloud_server.web.*.ipv4_address}"
  private_ips   = "${hcloud_server.web.*.ipv4_address}"
  overlay_cidr  = "10.10.10.0/24"
}