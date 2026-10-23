resource "google_compute_ha_vpn_gateway" "this" {
  project = var.project_id
  name    = var.gateway_name
  region  = var.region
  network = var.network
}

resource "google_compute_external_vpn_gateway" "this" {
  project         = var.project_id
  name            = var.external_gateway_name
  description     = var.external_gateway_description
  redundancy_type = var.peer_redundancy_type

  dynamic "interface" {
    for_each = var.peer_interfaces

    content {
      id         = tonumber(interface.key)
      ip_address = interface.value.ip_address
    }
  }
}

resource "google_compute_router" "this" {
  project = var.project_id
  name    = var.router_name
  region  = var.region
  network = var.network

  bgp {
    asn            = var.local_asn
    advertise_mode = var.router_advertise_mode

    dynamic "advertised_ip_ranges" {
      for_each = var.router_advertise_mode == "CUSTOM" ? var.advertised_ip_ranges : {}

      content {
        range       = advertised_ip_ranges.key
        description = advertised_ip_ranges.value.description
      }
    }
  }
}

resource "google_compute_vpn_tunnel" "this" {
  for_each = var.tunnels

  project                         = var.project_id
  name                            = each.key
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.this.id
  vpn_gateway_interface           = each.value.gateway_interface
  peer_external_gateway           = google_compute_external_vpn_gateway.this.id
  peer_external_gateway_interface = each.value.peer_gateway_interface
  shared_secret                   = coalesce(each.value.shared_secret, var.ipsec_shared_secret)
  router                          = google_compute_router.this.id

  depends_on = [
    google_compute_external_vpn_gateway.this
  ]
}

resource "google_compute_router_interface" "this" {
  for_each = var.tunnels

  project    = var.project_id
  name       = "${each.key}-interface"
  router     = google_compute_router.this.name
  region     = var.region
  vpn_tunnel = google_compute_vpn_tunnel.this[each.key].name
  ip_range   = each.value.bgp_interface_range
}

resource "google_compute_router_peer" "this" {
  for_each = var.tunnels

  project                   = var.project_id
  name                      = "${each.key}-peer"
  router                    = google_compute_router.this.name
  region                    = var.region
  interface                 = google_compute_router_interface.this[each.key].name
  peer_ip_address           = each.value.bgp_peer_ip
  peer_asn                  = tostring(var.peer_asn)
  advertised_route_priority = each.value.advertised_route_priority

  dynamic "md5_authentication_key" {
    for_each = each.value.md5_authentication_key != null ? [1] : []
    content {
      name = "${each.key}-md5"
      key  = each.value.md5_authentication_key
    }
  }
}