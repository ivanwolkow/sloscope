# GitHub bootstrap

This independent Terraform configuration recreates the GitHub setup for SLOscope:
the public repository and selected settings, `dns-production` and `github-pages`
environments, the Pages environment's `main` branch policy, Actions-based Pages
with a custom domain, and the `CLARITY_PROJECT_ID` repository variable.

The explicit deployment file `environments/sloscope.tfvars` matches
`ivanwolkow/sloscope`. Its baseline plan is
**6 to import, 0 to add, 0 to change, 0 to destroy**. No GitHub changes have been
applied by this implementation. Authentication is supplied externally.

## Credentials and state

Set `GITHUB_TOKEN` to a personal access token with access to the target repository
and permission to manage repository settings, environments, Pages and variables.
For a classic token, the provider documents `repo` scope; fine-grained tokens
need the corresponding endpoint permissions (Administration, Environments,
Pages and Variables). Creating a new repository also requires permission to
create it under the target owner. Permission to update Secrets is additionally
needed for the optional secret-installation script. Workflow files are pushed
using Git credentials with permission to push `.github/workflows`.

The bootstrap uses local state initially, independent of DNS state. It can run
before GitHub Actions or an HCP workspace exists. Keep `terraform.tfstate`
securely: it is ignored by Git, and losing it loses ownership tracking. Local
state is suitable for this single-operator experiment; use a shared backend
before running it from multiple machines or CI. Never use the DNS workspace
for this configuration.

To authenticate in zsh without recording the token in shell history:

```zsh
read -rs 'GITHUB_TOKEN?GitHub token: '; echo
export GITHUB_TOKEN
```

If GitHub CLI is already authenticated, an alternative is:

```sh
export GITHUB_TOKEN="$(gh auth token)"
```

## Adopt the current repository

From the repository root, with Terraform 1.13 or later installed:

```sh
terraform -chdir=infra/github init
terraform -chdir=infra/github plan -var-file=environments/sloscope.tfvars -out=github.tfplan
```

Review the six imports and ensure there are no mutations, then:

```sh
terraform -chdir=infra/github apply github.tfplan
terraform -chdir=infra/github plan -var-file=environments/sloscope.tfvars
```

The second plan should show no changes. Applying a saved plan does not prompt.
The repository has `prevent_destroy` enabled to guard against accidental deletion.
We do not manage Git history, default branch, security settings, collaborators,
Actions permission policies, account credentials or secret values through these
Terraform resources. Existing settings outside the declared scope remain outside
our configuration. The Pages field on the repository resource is ignored because
the separate Pages resource owns it.

## Create a new repository

Use a separate directory copy and fresh state for the new target. Do not change
the owner of an already managed repository to perform a migration. Copy the
`.tf` files, `terraform.tfvars.example` and `.terraform.lock.hcl` only, not
`.terraform`, state or plan files.

Copy `terraform.tfvars.example` to `terraform.tfvars` in that copy and edit it.
Terraform automatically loads `terraform.tfvars`; example files and files in
`environments/` are not automatically loaded. The owner, repository name and
Clarity ID are required inputs with no deployment-specific defaults. Generic
options default to new-repository mode, Pages disabled and no custom domain.
The example uses an empty Clarity ID to disable analytics.

For adopting another existing deployment, set `adopt_existing = true`, enable
Pages if appropriate and supply the existing `github-pages` main branch policy
ID. This adoption mode expects the same environment and variable names as
SLOscope; adapt the resources for a different repository layout.

1. Initialize, plan and apply. Terraform creates an empty repository, environments,
   the environment branch policy and Clarity variable.
2. Push this Git repository's history and workflow files to the new remote:

   ```sh
   git remote add migration git@github.com:YOUR_ACCOUNT_OR_ORGANIZATION/sloscope.git
   git push migration main
   ```

3. Set `configure_pages = true` and plan/apply again. `main` now exists, so Pages
   can be enabled. The Pages workflow may also enable it on the first push; if
   that happens, import `github_repository_pages.site[0]` with the repository name
   before applying this step. Run the Pages workflow after setup if necessary.
4. Initially use the default GitHub Pages address. Custom-domain cutover is a
   separate step: update DNS for the new owner, set `pages_domain`, and enable
   HTTPS enforcement only after the certificate is ready. Ensure domain
   verification and the old repository's custom-domain settings are handled.
5. For the DNS workflow, either keep using its existing HCP state for the same
   domain or configure independent DNS infrastructure for a different domain.
   The committed DNS resources target SLOscope; review them before running on a
   new deployment.

## Install DNS secrets

GitHub cannot return existing secret values. Supply them again from a password
manager via environment variables, then run:

```sh
bash infra/github/set-dns-secrets.sh OWNER/REPOSITORY
```

The script requires `SPACESHIP_API_KEY`, `SPACESHIP_API_SECRET`, and
`TF_TOKEN_app_terraform_io`. It writes `SPACESHIP_API_KEY`, `SPACESHIP_API_SECRET`,
and `TF_API_TOKEN` into `dns-production`. Authenticate GitHub CLI via
`GITHUB_TOKEN`, `GH_TOKEN`, or `gh auth login`. It overwrites those secret values;
run it only for the intended repository. Do not run with shell tracing enabled.
Secret values are sent via stdin and do not enter Terraform state.

## Move state to HCP later

Create a separate `sloscope-github` workspace in HCP with **Local** execution mode.
Replace `backend "local" {}` with a remote backend containing your hostname,
organization and that workspace name, supply `TF_TOKEN_app_terraform_io`, and run
`terraform -chdir=infra/github init -migrate-state`. Keep the DNS workspace separate.

Pull requests touching this directory run credential-free validation. Bootstrap
plan/apply remains local so it does not depend on the repository it configures.

References:
- https://registry.terraform.io/providers/integrations/github/latest/docs
- https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_pages
- https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret

## Outputs

`outputs.tf` exposes the resulting repository identifier and Git SSH URL for
convenience. These outputs are not required to create resources. After applying,
use `terraform -chdir=infra/github output -raw repository_ssh_url` to get the Git
remote URL, or `output -raw repository_full_name` for the secret-installation script.
