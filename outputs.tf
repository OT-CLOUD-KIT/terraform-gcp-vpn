
output "ha_vpn_gateway_id" {
  description = "ID of the HA VPN gateway."
  value       = google_compute_ha_vpn_gateway.this.id
}

output "ha_vpn_gateway_self_link" {
  description = "Self-link of the HA VPN gateway."
  value       = google_compute_ha_vpn_gateway.this.self_link
}

output "external_gateway_id" {
  description = "ID of the external peer gateway resource."
  value       = google_compute_external_vpn_gateway.this.id
}

output "cloud_router_id" {
  description = "ID of the Cloud Router."
  value       = google_compute_router.this.id
}

output "vpn_tunnel_names" {
  description = "Names of the VPN tunnels."
  value       = { for key, tunnel in google_compute_vpn_tunnel.this : key => tunnel.name }
}

output "vpn_tunnel_self_links" {
  description = "Self-links of the VPN tunnels."
  value       = { for key, tunnel in google_compute_vpn_tunnel.this : key => tunnel.self_link }
}

output "bgp_peer_names" {
  description = "Names of the Cloud Router BGP peers."
  value       = { for key, peer in google_compute_router_peer.this : key => peer.name }
}
