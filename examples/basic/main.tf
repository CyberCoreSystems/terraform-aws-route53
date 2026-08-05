provider "aws" {
  region = var.region
}

# Minimal runnable example: a public hosted zone with one A record and one
# apex TXT record, wired through the module with map-driven records.
module "dns" {
  source = "../.."

  zone_name = var.zone_name
  comment   = "Example zone managed by IaC Bazaar"

  records = {
    www = {
      name    = "www"
      type    = "A"
      ttl     = 300
      records = ["192.0.2.10"] # TEST-NET-1 documentation address
    }
    spf = {
      name    = "@"
      type    = "TXT"
      ttl     = 300
      records = ["\"v=spf1 -all\""]
    }
  }

  tags = {
    Environment = "example"
    ManagedBy   = "iac-bazaar"
  }
}
