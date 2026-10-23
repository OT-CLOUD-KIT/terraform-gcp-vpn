
module "vpn" {
  source = "../../"

  project_id            = var.project_id
  region                = var.region
  network               = var.network
  gateway_name          = "demo-ha-vpn-gateway"
  router_name           = "demo-ha-vpn-router"
  external_gateway_name = "demo-external-peer"

  peer_redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"

  peer_interfaces = {
    "0" = {
      ip_address = var.peer_ip_address
    }
  }

  local_asn           = var.local_asn
  peer_asn            = var.peer_asn
  ipsec_shared_secret = var.ipsec_shared_secret

  tunnels = {
    "demo-ha-vpn-tunnel-0" = {
      gateway_interface        = 0
      peer_gateway_interface   = 0
      bgp_interface_range      = "169.254.0.1/30"
      bgp_peer_ip              = "169.254.0.2"
      advertised_route_priority = 100
    }

    "demo-ha-vpn-tunnel-1" = {
      gateway_interface        = 1
      peer_gateway_interface   = 0
      bgp_interface_range      = "169.254.1.1/30"
      bgp_peer_ip              = "169.254.1.2"
      advertised_route_priority = 100
    }
  }

  router_advertise_mode = "DEFAULT"
}

