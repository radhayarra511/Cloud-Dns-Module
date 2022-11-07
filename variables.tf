variable "dns_name" {
  description = "Zone domain, must end with a period."
  type        = string
  default = ""
}

variable "zone_name" {
  description = "Zone name, must be unique within the project."
  type        = string
  default = ""
}

variable "authorized_networks_list" {
  description = "List of VPC self links that can see this zone."
  default     = []
  type        = list(string)
}

variable "project_id" {
  description = "Project id for the zone."
  type        = string
}

variable "target_name_server_addresses" {
  description = "List of target name servers for forwarding zone."
  default     = []
  type        = list(string)
}

variable "target_network" {
  description = "Peering network."
  default     = ""
}

variable "description" {
  description = "(Optional) A textual description field. Defaults to 'Managed by Terraform'."
  default     = "Managed by Terraform"
  type        = string
}

variable "dns_type" {
  description = "Type of zone to create, valid values are 'public', 'private', 'forwarding', 'peering'."
  default     = "private"
  type        = string
}

variable "dnssec_config" {
  description = "Object containing : kind, non_existence, state. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone.html#dnssec_config for futhers details"
  type        = any
  default     = {}
}

variable "labels" {
  type        = map(any)
  description = "A set of key/value label pairs to assign to this ManagedZone"
  default     = {}
}

variable "default_key_specs_key" {
  description = "Object containing default key signing specifications : algorithm, key_length, key_type, kind. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone.html#dnssec_config for futhers details"
  type        = any
  default     = {}
}

variable "default_key_specs_zone" {
  description = "Object containing default zone signing specifications : algorithm, key_length, key_type, kind. Please see https://www.terraform.io/docs/providers/google/r/dns_managed_zone.html#dnssec_config for futhers details"
  type        = any
  default     = {}
}

variable "recordsets" {
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  description = "List of DNS record objects to manage, in the standard terraform dns structure."
  default     = []
}

variable "dns_policy_name" {
  type        = string
  description = "(Required) User assigned name for this policy."
  default = ""
}

variable "enable_inbound_forwarding" {
  type        = bool
  description = "(Optional) Allows networks bound to this policy to receive DNS queries sent by VMs or applications over VPN connections. When enabled, a virtual IP address will be allocated from each of the sub-networks that are bound to this policy."
  default     = true
}

variable "enable_logging" {
  type        = bool
  description = "(Optional) Controls whether logging is enabled for the networks bound to this policy. Defaults to no logging if not set."
  default     = true
}

variable "alternative_name_server_config" {
  type        = list(map(any))
  description = "(Optional) Sets an alternative name server for the associated networks. When specified, all DNS queries are forwarded to a name server that you choose. Names such as .internal are not available when an alternative name server is specified. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_policy"
  default     = []
}
