output "zone_id" {
  description = "Hosted zone ID (use as zone_id for records and alias targets)."
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "ARN of the hosted zone."
  value       = aws_route53_zone.this.arn
}

output "zone_name" {
  description = "Name of the hosted zone."
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Authoritative name servers for the zone. Set these as the NS / delegation records at your registrar (public zones). Empty for private zones."
  value       = aws_route53_zone.this.name_servers
}

output "primary_name_server" {
  description = "Primary (SOA) name server for the zone."
  value       = aws_route53_zone.this.primary_name_server
}

output "is_private" {
  description = "True when the zone is private (associated with at least one VPC)."
  value       = local.is_private
}

output "record_fqdns" {
  description = "Map of record logical id to the fully-qualified name created."
  value       = { for k, r in aws_route53_record.this : k => r.fqdn }
}
