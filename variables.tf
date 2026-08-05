variable "zone_name" {
  description = "DNS name for the hosted zone, e.g. \"example.com\". A trailing dot is optional. By default a PUBLIC hosted zone is created; set vpc_ids to make it private."
  type        = string

  validation {
    condition     = can(regex("^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,63}\\.?$", var.zone_name))
    error_message = "zone_name must be a valid DNS name with at least two labels (e.g. example.com); a single trailing dot is allowed."
  }
}

variable "comment" {
  description = "Comment stored on the hosted zone."
  type        = string
  default     = "Managed by IaC Bazaar"

  validation {
    condition     = length(var.comment) <= 256
    error_message = "comment must be 256 characters or fewer (Route 53 limit)."
  }
}

variable "force_destroy" {
  description = "Destroy all records in the zone (including any created outside Terraform) when the zone is destroyed. Secure default is false so you never silently delete unmanaged records; the live-test fixture sets it true for guaranteed teardown."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Private hosted zone (optional). Leave vpc_ids empty for a public zone.
# ---------------------------------------------------------------------------

variable "vpc_ids" {
  description = "VPC IDs to associate with the zone. A non-empty list makes the zone PRIVATE (resolvable only inside those VPCs). Empty = public hosted zone."
  type        = list(string)
  default     = []
}

variable "vpc_region" {
  description = "Region of the associated VPCs (private zones only). Null uses the provider's region."
  type        = string
  default     = null
}

variable "delegation_set_id" {
  description = "Reusable delegation set ID to pin the zone's name servers (public zones only; conflicts with a private zone)."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Records (map-driven). The map key is a stable logical id you choose.
# ---------------------------------------------------------------------------

variable "records" {
  description = <<-EOT
    DNS records to create, keyed by a stable logical id.

    Per record:
      name    - relative label ("www"), apex ("@" or ""), or a full FQDN.
                It is normalised to a name inside the zone for you.
      type    - record type (A, AAAA, CNAME, TXT, MX, NS, SRV, CAA, ...).
      ttl     - TTL in seconds (default 300). Ignored for alias records.
      records - rdata values. Required UNLESS alias is set. TXT values must be
                wrapped in escaped double quotes, e.g. ["\"v=spf1 -all\""].
      alias   - alias target { name, zone_id, evaluate_target_health }. Mutually
                exclusive with records (used for ALB/CloudFront/S3-website/etc).
      set_identifier  - required when using a routing policy across multiple
                        records that share name+type.
      health_check_id - associate a Route 53 health check.
      allow_overwrite - adopt a pre-existing record of the same name+type.
  EOT
  type = map(object({
    name            = string
    type            = string
    ttl             = optional(number, 300)
    records         = optional(list(string), [])
    set_identifier  = optional(string)
    health_check_id = optional(string)
    allow_overwrite = optional(bool, false)
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for r in values(var.records) :
      contains(["A", "AAAA", "CAA", "CNAME", "DS", "MX", "NAPTR", "NS", "PTR", "SPF", "SRV", "TXT"], r.type)
    ])
    error_message = "Each record.type must be one of A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SPF, SRV, TXT."
  }

  validation {
    condition = alltrue([
      for r in values(var.records) :
      (r.alias != null) != (length(r.records) > 0)
    ])
    error_message = "Each record must set EITHER records (rdata) OR alias, but not both and not neither."
  }

  validation {
    condition = alltrue([
      for r in values(var.records) :
      r.ttl >= 0 && r.ttl <= 2147483647
    ])
    error_message = "record.ttl must be between 0 and 2147483647 seconds."
  }
}

variable "tags" {
  description = "Tags applied to the hosted zone."
  type        = map(string)
  default     = {}
}
