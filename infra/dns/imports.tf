# Adopt the existing records without creating replacements. These blocks can
# remain after import; Terraform skips records already tracked in state.
locals {
  # Fixed migration inventory: future records should be created, not imported.
  existing_record_ids = {
    apex_108 = "${var.domain}/A/@/185.199.108.153"
    apex_109 = "${var.domain}/A/@/185.199.109.153"
    apex_110 = "${var.domain}/A/@/185.199.110.153"
    apex_111 = "${var.domain}/A/@/185.199.111.153"
    www      = "${var.domain}/CNAME/www/ivanwolkow.github.io"
  }
}

import {
  for_each = { for key, id in local.existing_record_ids : key => id if contains(keys(var.web_records), key) }
  to       = spaceship_dns_record.web[each.key]
  id       = each.value
}
