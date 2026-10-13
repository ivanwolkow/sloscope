variable "github_owner" {
  description = "GitHub account or organization that owns the repository."
  type        = string
}

variable "repository_name" {
  description = "Name of the repository to manage."
  type        = string
}

variable "adopt_existing" {
  description = "Import an existing repository and its settings; false creates a new setup."
  type        = bool
  default     = false

  validation {
    condition     = !var.adopt_existing || var.existing_pages_branch_policy_id != null
    error_message = "When adopting an existing setup, supply its Pages environment branch policy ID."
  }
}

variable "existing_pages_branch_policy_id" {
  description = "Existing github-pages main deployment policy ID, used only for import."
  type        = string
  default     = null
}

variable "configure_pages" {
  description = "For a new repository, enable after pushing code and creating main."
  type        = bool
  default     = false
}

variable "pages_domain" {
  description = "Custom domain; use null for GitHub's default domain during migration."
  type        = string
  default     = null
}

variable "pages_https_enforced" {
  description = "Enable after the custom domain certificate is available."
  type        = bool
  default     = false
}

variable "clarity_project_id" {
  description = "Clarity project ID; use an empty string to disable analytics."
  type        = string
}
