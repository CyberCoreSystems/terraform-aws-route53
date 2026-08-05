# Route 53 hosted zone (public by default, private when vpc_ids is set) plus a
# map-driven set of records. Record names are normalised to the zone, and the
# alias-vs-rdata distinction is handled for you so plans stay clean.

locals {
  # A non-empty vpc_ids list turns this into a private hosted zone.
  is_private = length(var.vpc_ids) > 0

  # Zone name without a trailing dot, used to build fully-qualified record names.
  zone_fqdn = trimsuffix(var.zone_name, ".")

  # Normalise each record's name to a name inside the zone:
  #   "@" / ""                 -> the zone apex
  #   "<zone>" / "<zone>."     -> the zone apex
  #   "name.<zone>."           -> trailing dot stripped
  #   "name.<zone>"            -> used as-is
  #   "name"                   -> "name.<zone>"
  records = {
    for k, r in var.records : k => merge(r, {
      fqdn = (
        r.name == "" || r.name == "@" || r.name == local.zone_fqdn || r.name == "${local.zone_fqdn}." ? local.zone_fqdn :
        endswith(r.name, ".") ? trimsuffix(r.name, ".") :
        endswith(r.name, ".${local.zone_fqdn}") ? r.name :
        "${r.name}.${local.zone_fqdn}"
      )
    })
  }
}

resource "aws_route53_zone" "this" {
  name          = var.zone_name
  comment       = var.comment
  force_destroy = var.force_destroy

  # delegation_set_id is only valid for public zones (conflicts with vpc).
  delegation_set_id = local.is_private ? null : var.delegation_set_id

  # Presence of one or more vpc blocks makes the zone private.
  dynamic "vpc" {
    for_each = toset(var.vpc_ids)
    content {
      vpc_id     = vpc.value
      vpc_region = var.vpc_region
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "this" {
  for_each = local.records

  zone_id         = aws_route53_zone.this.zone_id
  name            = each.value.fqdn
  type            = each.value.type
  set_identifier  = each.value.set_identifier
  health_check_id = each.value.health_check_id
  allow_overwrite = each.value.allow_overwrite

  # Standard records carry ttl + rdata; alias records carry neither.
  ttl     = each.value.alias == null ? each.value.ttl : null
  records = each.value.alias == null ? each.value.records : null

  dynamic "alias" {
    for_each = each.value.alias == null ? [] : [each.value.alias]
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }
}
