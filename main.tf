resource "null_resource" "wireguard" {
  count       = "${var.count}"
  depends_on  = ["null_resource.setup"]

  triggers {
    count = "${var.count}"
  }

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  # Update interface conf
  provisioner "file" {
    content     = "${element(data.template_file.interface_conf.*.rendered, count.index)}"
    destination = "/etc/wireguard/${var.interface}.conf"
  }

  provisioner "file" {
    destination = "/etc/systemd/system/${local.network_route_systemd_unit}"
    content = "${element(data.template_file.network_route_service.*.rendered, count.index)}"
  }

  # Dynamically adding peers, without restart of whole interface
  provisioner "remote-exec" {
    inline = <<EOF
${element(data.template_file.add_peers.*.rendered, count.index)}
EOF
  }
}

data "template_file" "add_peers" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/add_peers.sh")}"

  vars {
    interface   = "${var.interface}"
    peers       = "${replace(join("\n", data.template_file.add_peer.*.rendered), element(data.template_file.add_peer.*.rendered, count.index), "")}"
  }
}

data "template_file" "add_peer" {
  count    = "${var.count}"
  template = "${file("${path.module}/templates/add_peer.sh")}"

  vars {
    interface    = "${var.interface}"
    ip           = "${element(var.private_ips, count.index)}"
    port         = "${var.port}"
    public_key   = "${element(data.null_data_source.wireguard.*.outputs.public_key, count.index)}"
    allowed_cidr = "${element(data.template_file.ips.*.rendered, count.index)}/32"
  }
}

data "template_file" "ips" {
  count    = "${var.count}"
  template = "$${ip}"

  vars {
    ip = "${cidrhost(var.network_cidr, count.index + 1)}"
  }
}

data "external" "generate_key" {
  count = "${var.count}"

  program = ["sh", "${path.module}/scripts/generate_key.sh"]

  query {
    keys_dir = "${var.keys_dir}"
    id       = "${md5(join(",", list(var.interface, var.port, element(data.template_file.ips.*.rendered, count.index))))}"
  }
}

data "null_data_source" "wireguard" {
  count = "${var.count}"

  inputs {
    private_key = "${element(data.external.generate_key.*.result.private_key, count.index)}"
    public_key  = "${element(data.external.generate_key.*.result.public_key, count.index)}"
  }
}