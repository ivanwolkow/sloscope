provider "spaceship" {}

# Only explicitly declared web records are managed. Other records stay in Spaceship.
resource "spaceship_dns_record" "web" {
  for_each = var.web_records

  domain  = var.domain
  type    = each.value.type
  name    = each.value.name
  ttl     = each.value.ttl
  address = each.value.address
  cname   = each.value.cname
}
