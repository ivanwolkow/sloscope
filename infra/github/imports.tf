import {
  for_each = var.adopt_existing ? toset([var.repository_name]) : toset([])
  to       = github_repository.project
  id       = each.value
}

import {
  for_each = var.adopt_existing ? toset(["${var.repository_name}:dns-production"]) : toset([])
  to       = github_repository_environment.dns
  id       = each.value
}

import {
  for_each = var.adopt_existing ? toset(["${var.repository_name}:github-pages"]) : toset([])
  to       = github_repository_environment.pages
  id       = each.value
}

import {
  for_each = var.adopt_existing && var.existing_pages_branch_policy_id != null ? toset(["${var.repository_name}:github-pages:${var.existing_pages_branch_policy_id}"]) : toset([])
  to       = github_repository_environment_deployment_policy.pages_main
  id       = each.value
}

import {
  for_each = var.adopt_existing && var.configure_pages ? toset([var.repository_name]) : toset([])
  to       = github_repository_pages.site[0]
  id       = each.value
}

import {
  for_each = var.adopt_existing ? toset(["${var.repository_name}:CLARITY_PROJECT_ID"]) : toset([])
  to       = github_actions_variable.clarity
  id       = each.value
}
