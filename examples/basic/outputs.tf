output "zone_id" {
  description = "Hosted zone ID."
  value       = module.dns.zone_id
}

output "name_servers" {
  description = "Name servers to set at your registrar to delegate the zone."
  value       = module.dns.name_servers
}

output "record_fqdns" {
  description = "Fully-qualified names of the records created."
  value       = module.dns.record_fqdns
}
