provider "github" {
  owner = var.github_owner
}

resource "github_repository" "project" {
  name                   = var.repository_name
  description            = "Interactive SLI/SLO simulator and visualizer for latency-based reliability metrics: model request-latency distributions, define sliding-window SLI and burn windows, and monitor SLI, error budget remaining, and burn rate in real time."
  visibility             = "public"
  has_issues             = true
  has_projects           = true
  has_wiki               = false
  has_discussions        = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  allow_auto_merge       = false
  allow_update_branch    = false
  delete_branch_on_merge = false
  auto_init              = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [pages]
  }
}

resource "github_repository_environment" "dns" {
  repository  = github_repository.project.name
  environment = "dns-production"
}

resource "github_repository_environment" "pages" {
  repository  = github_repository.project.name
  environment = "github-pages"

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "pages_main" {
  repository     = github_repository.project.name
  environment    = github_repository_environment.pages.environment
  branch_pattern = "main"
}

resource "github_repository_pages" "site" {
  count          = var.configure_pages ? 1 : 0
  repository     = github_repository.project.name
  build_type     = "workflow"
  cname          = var.pages_domain
  https_enforced = var.pages_domain != null && var.pages_https_enforced
}

resource "github_actions_variable" "clarity" {
  repository    = github_repository.project.name
  variable_name = "CLARITY_PROJECT_ID"
  value         = var.clarity_project_id
}
