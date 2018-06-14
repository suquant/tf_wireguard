resource "null_resource" "install" {
  count   = "${var.count}"

  connection {
    host  = "${element(var.connections, count.index)}"
    user  = "root"
    agent = true
  }

  # Install service packages
  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt install -yq apt-transport-https ca-certificates software-properties-common"
    ]
  }

  # Enable ipv4 forwarding
  provisioner "remote-exec" {
    inline = [
      "echo net.ipv4.ip_forward=1 > /etc/sysctl.d/ipv4_forward.conf",
      "sysctl -w net.ipv4.ip_forward=1"
    ]
  }

  # Add wireguard repo
  provisioner "remote-exec" {
    inline = [
      "add-apt-repository -y ppa:wireguard/wireguard",
      "apt update"
    ]
  }

  # Install wireguard
  provisioner "remote-exec" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt install -y wireguard linux-headers-$(uname -r) linux-headers-virtual"
    ]
  }
}