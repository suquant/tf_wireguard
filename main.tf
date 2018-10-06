variable "count" {}

variable "connections" {
  type = "list"
}

variable "private_ips" {
  type = "list"
}

variable "vpn_interface" {
  default = "wg0"
}

variable "vpn_port" {
  default = "51820"
}

variable "vpn_cidr" {
  default = "172.16.10.0/24"
}

variable "overlay_cidr" {
  type = "string"
}

locals {
  interface_unit      = "wg-quick@${var.vpn_interface}.service"
  private_key_file    = "/etc/wireguard/${var.vpn_interface}.key"
  overlay_route_unit  = "overlay-route-${var.vpn_interface}.service"
}


resource "null_resource" "wireguard" {
  count   = "${var.count}"

  triggers {
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo net.ipv4.ip_forward=1 > /etc/sysctl.d/ipv4_forward.conf",
      "sysctl -w net.ipv4.ip_forward=1"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt install -yq apt-transport-https ca-certificates software-properties-common",
      "add-apt-repository -y ppa:wireguard/wireguard",
      "apt update",
      "DEBIAN_FRONTEND=noninteractive apt install -y wireguard linux-headers-$(uname -r) linux-headers-virtual"
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.interface_conf.*.rendered, count.index)}"
    destination = "/etc/wireguard/${var.vpn_interface}.conf"
  }

  provisioner "file" {
    destination = "/etc/systemd/system/${local.overlay_route_unit}"
    content = "${element(data.template_file.overlay_route.*.rendered, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 700 /etc/wireguard/${var.vpn_interface}.conf",
      "systemctl is-enabled ${local.interface_unit} || systemctl enable ${local.interface_unit}",
      "systemctl restart ${local.interface_unit}",

      "systemctl is-enabled ${local.overlay_route_unit} || systemctl enable ${local.overlay_route_unit}",
      "systemctl start ${local.overlay_route_unit}"
    ]
  }

}

data "template_file" "interface_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/interface.conf")}"

  vars {
    vpn_interface = "${var.vpn_interface}"
    vpn_ip        = "${element(data.template_file.vpn_ips.*.rendered, count.index)}"
    vpn_port      = "${var.vpn_port}"
    private_key   = "${element(data.external.keys.*.result.private_key, count.index)}"
    peers         = "${replace(join("\n", data.template_file.peer_conf.*.rendered), element(data.template_file.peer_conf.*.rendered, count.index), "")}"
  }
}

data "template_file" "peer_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/peer.conf")}"

  vars {
    endpoint     = "${element(var.private_ips, count.index)}"
    vpn_port     = "${var.vpn_port}"
    public_key   = "${element(data.external.keys.*.result.public_key, count.index)}"
    allowed_cidr = "${element(data.template_file.vpn_ips.*.rendered, count.index)}/32"
  }
}

data "template_file" "overlay_route" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/overlay-route.service")}"

  vars {
    after_unit    = "${local.interface_unit}"
    vpn_interface = "${var.vpn_interface}"
    vpn_ip        = "${element(data.template_file.vpn_ips.*.rendered, count.index)}"
    overlay_cidr  = "${var.overlay_cidr}"
  }
}

data "template_file" "vpn_ips" {
  count    = "${var.count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.vpn_cidr, count.index + 1)}"
  }
}

data "external" "keys" {
  count = "${var.count}"

  program = ["sh", "${path.module}/scripts/gen_keys.sh"]
}


output "public_ips" {
  value = "${var.connections}"

  depends_on = ["null_resource.wireguard"]
}

output "private_ips" {
  value = "${var.private_ips}"

  depends_on = ["null_resource.wireguard"]
}

output "vpn_ips" {
  value      = "${data.template_file.vpn_ips.*.rendered}"

  depends_on = ["null_resource.wireguard"]
}

output "vpn_interface_unit" {
  value      = "${local.interface_unit}"

  depends_on = ["null_resource.wireguard"]
}

output "overlay_route_unit" {
  value      = "${local.overlay_route_unit}"

  depends_on = ["null_resource.wireguard"]
}

output "vpn_interface" {
  value = "${var.vpn_interface}"

  depends_on = ["null_resource.wireguard"]
}

output "vpn_port" {
  value = "${var.vpn_port}"

  depends_on = ["null_resource.wireguard"]
}

output "overlay_cidr" {
  value = "${var.overlay_cidr}"

  depends_on = ["null_resource.wireguard"]
}

output "vpn_cidr" {
  value = "${var.vpn_cidr}"

  depends_on = ["null_resource.wireguard"]
}