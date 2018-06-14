resource "null_resource" "setup" {
  count       = "${var.count}"
  depends_on  = ["null_resource.install"]

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  provisioner "file" {
    content     = "${element(data.template_file.interface_conf.*.rendered, count.index)}"
    destination = "/etc/wireguard/${var.interface}.conf"
  }

  provisioner "file" {
    destination = "/etc/systemd/system/${local.network_route_systemd_unit}"
    content = "${element(data.template_file.network_route_service.*.rendered, count.index)}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 700 /etc/wireguard/${var.interface}.conf",

      "systemctl is-enabled ${local.systemd_unit} || systemctl enable ${local.systemd_unit}",
      "systemctl start ${local.systemd_unit}",

      "systemctl is-enabled ${local.network_route_systemd_unit} || systemctl enable ${local.network_route_systemd_unit}",
      "systemctl start ${local.network_route_systemd_unit}"
    ]
  }
}

data "template_file" "interface_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/interface.conf")}"

  vars {
    interface    = "${var.interface}"
    ip           = "${element(data.template_file.ips.*.rendered, count.index)}"
    port         = "${var.port}"
    private_key  = "${element(data.null_data_source.wireguard.*.outputs.private_key, count.index)}"
    peers        = "${replace(join("\n", data.template_file.peer_conf.*.rendered), element(data.template_file.peer_conf.*.rendered, count.index), "")}"
  }
}

data "template_file" "peer_conf" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/peer.conf")}"

  vars {
    ip           = "${element(var.private_ips, count.index)}"
    port         = "${var.port}"
    public_key   = "${element(data.null_data_source.wireguard.*.outputs.public_key, count.index)}"
    allowed_cidr = "${element(data.template_file.ips.*.rendered, count.index)}/32"
  }
}

data "template_file" "network_route_service" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/network-route.service")}"

  vars {
    after         = "${local.systemd_unit}"
    interface     = "${var.interface}"
    ip            = "${element(data.template_file.ips.*.rendered, count.index)}"
    network_cidr  = "${var.network_cidr}"
  }
}