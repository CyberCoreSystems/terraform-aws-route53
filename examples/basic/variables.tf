variable "region" {
  description = "AWS region for the provider (Route 53 is global, but the provider still needs a region)."
  type        = string
  default     = "us-east-1"
}

variable "zone_name" {
  description = "DNS name for the public hosted zone created by this example."
  type        = string
  default     = "example.com"
}
