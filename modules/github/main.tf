# Load JSON files from the specified directory
locals {
  # Get list of JSON files in the directory
  filenames = fileset(var.repositories_dir, "*.json")
  
  # Read and parse each JSON file
  repos_from_files = [
    for filename in local.filenames : 
    jsondecode(file("${var.repositories_dir}/${filename}"))
  ]
}

# Data source to get all existing repositories in the organization
data "github_repositories" "existing" {
  query = "org:${var.organization}"
}

locals {
  # Create a set of existing repository names for efficient lookup
  existing_repos = toset(data.github_repositories.existing.names)
  
  # Filter out repositories that already exist
  repos_to_create = [
    for repo in local.repos_from_files : repo
    if !contains(local.existing_repos, repo.name)
  ]
  
  # Map of repositories to create
  repos_map = { for repo in local.repos_to_create : repo.name => repo }
}

resource "github_repository" "repos" {
  for_each = local.repos_map
  
  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility
  

  auto_init   = var.auto_init
  
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
}

# Create develop branch for each new repository
resource "github_branch" "develop" {
  for_each = github_repository.repos
  
  repository    = each.value.name
  branch        = "develop"
  source_branch = each.value.default_branch
}

# Set develop as default branch for each new repository
resource "github_branch_default" "default" {
  for_each = github_branch.develop
  
  repository = each.value.repository
  branch     = each.value.branch
}

# Add AWS secret to each new repository
resource "github_actions_secret" "aws_access_key_id" {
  for_each = github_repository.repos
  
  repository      = each.value.name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

# Add AWS secret to each new repository
resource "github_actions_secret" "aws_secret_access_key" {
  for_each = github_repository.repos
  
  repository      = each.value.name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

output "repositories_created" {
  value = {
    for name, repo in github_repository.repos : name => {
      url             = repo.html_url
      ssh_clone_url   = repo.ssh_clone_url
      default_branch  = github_branch_default.default[name].branch
    }
  }
  description = "Details of newly created repositories"
}

output "repositories_skipped" {
  value = [
    for repo in local.repos_from_files : repo.name
    if contains(local.existing_repos, repo.name)
  ]
  description = "List of repositories that already existed and were skipped"
}