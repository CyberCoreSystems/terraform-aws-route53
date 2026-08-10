# Route 53 Hosted Zone & Records

A Route 53 hosted zone (public or private via vpc_ids) plus a map-driven set of records, with name normalisation and the alias-vs-rdata distinction resolved and inputs validated.

This module was **applied to a real AWS account, verified, and destroyed** on 2026-06-30 — not just `terraform validate`d.

## Usage

```hcl
module "route53" {
  source  = "registry.terraform.io/CyberCoreSystems/route53/aws"
  version = "~> 1.0"

  # See variables.tf for the full input contract.
}
```

## Why this module

Every module we publish goes through the same gate before release:

| check | what it means |
|---|---|
| `tofu validate` + `tflint` | it parses and lints clean |
| `checkov` | scanned for insecure defaults |
| **live test** | **really applied to a cloud account, outputs verified, then destroyed** |

That last row is the one most module catalogues skip. A module that has never
been applied has never been proven.

## Provider compatibility

```
aws >= 6.0, < 7.0
```

## More modules

This is one of **183 verified Terraform modules across 19 cloud platforms** —
AWS, Azure, GCP, Oracle OCI, Cloudflare, Akamai, DigitalOcean, Linode, Hetzner,
Vultr, Scaleway, Alibaba, IBM, UpCloud, Civo, Exoscale, OVH, Tencent and Huawei.

Browse the full catalogue at **[www.iac-bazaar.com](https://www.iac-bazaar.com)**, including
production landing zones for AWS, Azure and GCP that have each been live-tested
as a single composed apply.

- Module page: [https://www.iac-bazaar.com/catalog/aws-route53](https://www.iac-bazaar.com/catalog/aws-route53)
- How verification works: [https://www.iac-bazaar.com/verified](https://www.iac-bazaar.com/verified)

## Licence

See [LICENSE](./LICENSE).
