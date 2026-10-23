
variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Region for the HA VPN gateway and Cloud Router."
  type        = string
  default     = "asia-south1"
}

variable "network" {
  description = "Self-link or ID of an existing VPC network."
  type        = string
}

variable "peer_ip_address" {
  description = "Public IP address of the external VPN peer. Replace the example value."
  type        = string
}

variable "local_asn" {
  description = "Private ASN for the Google Cloud Router."
  type        = number
  default     = 64514
}

variable "peer_asn" {
  description = "ASN configured on the external peer."
  type        = number
  default     = 64515
}

variable "ipsec_shared_secret" {
  description = "IPsec secret provided securely at deployment time."
  type        = string
  sensitive   = true
}
