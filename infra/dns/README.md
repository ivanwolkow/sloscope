# SLOscope DNS

This directory manages explicitly declared web DNS records for `sloscope.eu`
using `namecheap/spaceship`. Registration, renewal, nameservers, email and other
undeclared records are outside its scope. Never add `spaceship_dns_records`
(the whole-zone resource) alongside these individual resources.

The committed record map matches the five records shown in the Spaceship
dashboard: four apex A records and the `www` CNAME, all with TTL 1800 seconds.
The dashboard confirms `launch1.spaceship.net` and `launch2.spaceship.net` as
nameservers. No DNS changes have been applied.
`imports.tf` adopts these existing records during the first apply. First check
that the plan reports **5 to import, 0 to add, 0 to change, 0 to destroy**.
The import inventory contains only these five existing records; new entries in
`web_records` are created normally. Add an import entry separately when adopting
another existing record.

## Bootstrap

1. In Spaceship, check that the authoritative nameservers are Spaceship's.
   Export or copy the current DNS record table, including type, host, value and TTL.
2. Create an API key and secret in Spaceship API Manager with the DNS permissions
   required for the operation: `dnsrecords:read` for planning and imports, plus
   `dnsrecords:write` for DNS changes. Do not commit or paste credentials.
3. In the HCP Terraform organization `imwolkow-org`, create a CLI-driven workspace
   named `sloscope-dns`. Set its **execution mode to Local**: GitHub runs Terraform,
   while HCP stores state and provides locking. Do not connect VCS execution.
4. In GitHub, create the environment `dns-production`. Restrict it to the main
   branch (or master if used). Add environment secrets `SPACESHIP_API_KEY`,
   `SPACESHIP_API_SECRET`, and `TF_API_TOKEN` (an HCP token with workspace access).
5. Run a plan using the configured backend. The initial plan should contain only
   the five imports. After applying that import-only plan, expect no changes.

## Local use

Install Terraform 1.13 or later. Authenticate to HCP with `terraform login` and
set `SPACESHIP_API_KEY` and `SPACESHIP_API_SECRET` in your shell using a password
manager or a non-committed local mechanism.

The backend is configured in `versions.tf`. Local runs and GitHub Actions both
use the `sloscope-dns` workspace in `imwolkow-org` at `app.terraform.io`.
Alternatively to `terraform login`, supply `TF_TOKEN_app_terraform_io` in your shell.

Run from this directory:

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Populate `terraform.tfvars` with the actual records, preserving current values
and TTLs. Use a stable key for each record. For example (documentation address,
not the real SLOscope configuration):

```hcl
web_records = {
  apex_example = {
    type    = "A"
    name    = "@"
    ttl     = 3600
    address = "203.0.113.10"
  }
}
```

Import that existing A record with:

```sh
terraform import 'spaceship_dns_record.web["apex_example"]' 'sloscope.eu/A/@/203.0.113.10'
```

For CNAME records use `cname` instead of `address`. Verify the import ID against
the provider documentation. Commit the resulting configuration and dependency
lock file, never state, credentials or saved plans.

## GitHub Actions

Pull requests run formatting and provider validation without credentials or
access to production state. After merging, run **Terraform DNS** on main with
`plan` to inspect actual changes. Run it again with `apply` to create a fresh
plan and apply that saved plan. The apply run is a new plan, not the previous
run's plan; inspect it in its logs. Initially use `plan` only until imports are
complete and the baseline has no changes.

Both operations use the production environment; you may enable environment
reviewers if your GitHub plan supports them. Concurrent workflow runs are queued,
and remote state locking also protects against simultaneous local operations.
Plans are not uploaded as artifacts because they can contain sensitive data.
Removing a managed record from configuration deletes it on the next apply.
Record data changes may require replacement; CNAME changes in particular can
have a brief interruption. Review replacement plans before applying.

Provider docs: https://registry.terraform.io/providers/namecheap/spaceship/latest/docs/resources/dns_record
Remote backend: https://developer.hashicorp.com/terraform/language/backend/remote
