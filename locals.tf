locals {
  systemd_unit                = "wg-quick@${var.interface}.service"
  network_route_systemd_unit  = "${var.interface}-network-route.service"
  private_key_file            = "/etc/wireguard/${var.interface}.key"
}
