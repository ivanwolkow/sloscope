#!/usr/bin/env bash
set -euo pipefail

# Values travel over stdin, not command arguments or Terraform state.
# Authenticate gh with GH_TOKEN/GITHUB_TOKEN or gh auth login.
repository="${1:?Usage: bash set-dns-secrets.sh OWNER/REPOSITORY}"
command -v gh >/dev/null
for name in SPACESHIP_API_KEY SPACESHIP_API_SECRET TF_TOKEN_app_terraform_io; do
  if [[ -z "${!name:-}" ]]; then
    echo "Missing environment variable: $name" >&2
    exit 1
  fi
done

printf '%s' "$SPACESHIP_API_KEY" | gh secret set SPACESHIP_API_KEY --repo "$repository" --env dns-production
printf '%s' "$SPACESHIP_API_SECRET" | gh secret set SPACESHIP_API_SECRET --repo "$repository" --env dns-production
printf '%s' "$TF_TOKEN_app_terraform_io" | gh secret set TF_API_TOKEN --repo "$repository" --env dns-production
