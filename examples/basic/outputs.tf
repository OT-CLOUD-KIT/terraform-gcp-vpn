
output "ha_vpn_gateway_id" {
  value = module.vpn.ha_vpn_gateway_id
}

output "cloud_router_id" {
  value = module.vpn.cloud_router_id
}

output "vpn_tunnel_names" {
  value = module.vpn.vpn_tunnel_names
}

output "bgp_peer_names" {
  value = module.vpn.bgp_peer_names
}
