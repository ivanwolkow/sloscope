output "repository_full_name" {
  description = "OWNER/REPOSITORY identifier for CLI commands such as secret installation."
  value       = github_repository.project.full_name
}

output "repository_ssh_url" {
  description = "Git remote URL for pushing code after bootstrap."
  value       = github_repository.project.ssh_clone_url
}
