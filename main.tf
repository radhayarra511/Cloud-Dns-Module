resource "google_dns_managed_zone" "peering" {
  count       = var.dns_type == "peering" ? 1 : 0
  project     = var.project_id
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  labels      = var.labels
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = var.authorized_networks_list
      content {
        network_url = networks.value
      }
    }
  }

  peering_config {
    target_network {
      network_url = var.target_network
    }
  }
}

resource "google_dns_managed_zone" "forwarding" {
  count       = var.dns_type == "forwarding" ? 1 : 0
  project     = var.project_id
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  labels      = var.labels
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = var.authorized_networks_list
      content {
        network_url = networks.value
      }
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = var.target_name_server_addresses
      content {
        ipv4_address = target_name_servers.value
      }
    }
  }
}

resource "google_dns_managed_zone" "private" {
  count       = var.dns_type == "private" ? 1 : 0
  project     = var.project_id
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  labels      = var.labels
  visibility  = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = var.authorized_networks_list
      content {
        network_url = networks.value
      }
    }
  }
}

resource "google_dns_managed_zone" "public" {
  count       = var.dns_type == "public" ? 1 : 0
  project     = var.project_id
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  labels      = var.labels
  visibility  = "public"

  dynamic "dnssec_config" {
    for_each = var.dnssec_config == {} ? [] : list(var.dnssec_config)
    iterator = config
    content {
      kind          = lookup(config.value, "kind", "dns#managedZoneDnsSecConfig")
      non_existence = lookup(config.value, "non_existence", "nsec3")
      state         = lookup(config.value, "state", "off")

      default_key_specs {
        algorithm  = lookup(var.default_key_specs_key, "algorithm", "rsasha256")
        key_length = lookup(var.default_key_specs_key, "key_length", 2048)
        key_type   = lookup(var.default_key_specs_key, "key_type", "keySigning")
        kind       = lookup(var.default_key_specs_key, "kind", "dns#dnsKeySpec")
      }
      default_key_specs {
        algorithm  = lookup(var.default_key_specs_zone, "algorithm", "rsasha256")
        key_length = lookup(var.default_key_specs_zone, "key_length", 1024)
        key_type   = lookup(var.default_key_specs_zone, "key_type", "zoneSigning")
        kind       = lookup(var.default_key_specs_zone, "kind", "dns#dnsKeySpec")
      }
    }
  }

}

resource "google_dns_record_set" "cloud-static-records" {
  project      = var.project_id
  managed_zone = var.zone_name

  for_each =  var.dns_type != "policy" ? { for record in var.recordsets : join("/", [record.name, record.type]) => record } : {}
  name = (
    each.value.name != "" ?
    "${each.value.name}.${var.dns_name}" :
    var.dns_name
  )
  type = each.value.type
  ttl  = each.value.ttl

  rrdatas = each.value.records

  depends_on = [
    google_dns_managed_zone.private,
    google_dns_managed_zone.public,
  ]
}

resource "google_dns_policy" "dns_policy" {
  count                     = var.dns_type == "policy" ? 1 : 0
  name                      = var.dns_policy_name
  project                   = var.project_id
  description               = var.description
  enable_inbound_forwarding = var.enable_inbound_forwarding
  enable_logging            = var.enable_logging

  dynamic "alternative_name_server_config" {
    for_each = var.alternative_name_server_config

    content {
      dynamic "target_name_servers" {
        for_each = alternative_name_server_config.value.target_name_servers

        content {
          ipv4_address    = lookup(target_name_servers.value, "ipv4_address", null)
          forwarding_path = lookup(target_name_servers.value, "forwarding_path", null)
        }
      }
    }
  }

  dynamic "networks" {
    for_each = var.authorized_networks_list
    content {
      network_url = networks.value
    }
  }
}
