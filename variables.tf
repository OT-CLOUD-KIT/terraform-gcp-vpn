variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Region where the HA VPN gateway and Cloud Router will be created."
  type        = string
}

variable "network" {
  description = "Self-link or ID of an existing VPC network."
  type        = string
}

variable "gateway_name" {
  description = "Name of the HA VPN gateway."
  type        = string
  default     = "demo-ha-vpn"
}

variable "router_name" {
  description = "Name of the Cloud Router."
  type        = string
  default     = "demo-vpn-router"
}

variable "external_gateway_name" {
  description = "Name of the external peer VPN gateway resource."
  type        = string
  default     = "demo-peer-gateway"
}

variable "external_gateway_description" {
  description = "Description of the external peer gateway."
  type        = string
  default     = "Managed by Terraform"
}

variable "peer_redundancy_type" {
  description = "Redundancy type supported by the external peer gateway."
  type        = string
  default     = "SINGLE_IP_INTERNALLY_REDUNDANT"

  validation {
    condition = contains([
      "FOUR_IPS_REDUNDANCY",
      "TWO_IPS_REDUNDANCY",
      "SINGLE_IP_INTERNALLY_REDUNDANT",
      "SINGLE_IP_REDUNDANCY"
    ], var.peer_redundancy_type)
    error_message = "Use a supported external VPN gateway redundancy type."
  }
}

variable "peer_interfaces" {
  description = "External peer gateway interfaces, keyed by interface ID."
  type = map(object({
    ip_address = string
  }))

  validation {
    condition     = length(var.peer_interfaces) > 0
    error_message = "Provide at least one external peer gateway interface."
  }
}

variable "local_asn" {
  description = "Private ASN used by the Google Cloud Router (16-bit or 32-bit private ranges)."
  type        = number

  validation {
    condition = (
      (var.local_asn >= 64512 && var.local_asn <= 65534) ||
      (var.local_asn >= 4200000000 && var.local_asn <= 4294967294)
    )
    error_message = "local_asn must be a valid private ASN in range 64512-65534 or 4200000000-4294967294."
  }
}

variable "peer_asn" {
  description = "ASN configured on the external BGP peer."
  type        = number

  validation {
    condition     = var.peer_asn >= 1 && var.peer_asn <= 4294967295
    error_message = "peer_asn must be a valid 32-bit ASN."
  }
}

variable "ipsec_shared_secret" {
  description = "Default fallback IPsec shared secret if not specified per tunnel."
  type        = string
  sensitive   = true
  default     = null
}

variable "tunnels" {
  description = "VPN tunnel and BGP settings, keyed by tunnel name."
  type = map(object({
    gateway_interface         = number
    peer_gateway_interface    = number
    bgp_interface_range       = string
    bgp_peer_ip               = string
    shared_secret             = optional(string)
    advertised_route_priority = optional(number, 100)
    md5_authentication_key    = optional(string)
  }))

  validation {
    condition     = length(var.tunnels) >= 2
    error_message = "Configure at least two tunnels for HA VPN."
  }

  validation {
    condition = alltrue([
      for tunnel in values(var.tunnels) :
      contains([0, 1], tunnel.gateway_interface)
    ])
    error_message = "gateway_interface must be 0 or 1."
  }
}

variable "router_advertise_mode" {
  description = "Cloud Router BGP advertisement mode."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "CUSTOM"], var.router_advertise_mode)
    error_message = "router_advertise_mode must be DEFAULT or CUSTOM."
  }
}

variable "advertised_ip_ranges" {
  description = "Custom CIDR ranges and descriptions advertised to the peer when CUSTOM mode is selected."
  type = map(object({
    description = string
  }))
  default = {}
}