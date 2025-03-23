# Load JSON files from the specified directory
locals {
  filenames = fileset(var.repositories_dir, "*.json")

  repos_from_files = [
    for filename in local.filenames :
    jsondecode(file("${var.repositories_dir}/${filename}"))
  ]
}

# Fetch all existing repositories in the organization
data "github_repositories" "existing" {
  query = "org:${var.organization}"
}

locals {
  existing_repos = toset(data.github_repositories.existing.names)

  repos_to_create = [
    for repo in local.repos_from_files : repo
    if !contains(local.existing_repos, repo.name)
  ]

  repos_map = { for repo in local.repos_to_create : repo.name => repo }
}

# Create repositories
resource "github_repository" "repos" {
  for_each = local.repos_map

  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility

  auto_init = var.auto_init

  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true

  topics               = ["terraform-managed"]
  # Not available for free GitHub accounts
  # vulnerability_alerts = true
}

# Create 'develop' branch for each new repository
resource "github_branch" "develop" {
  for_each = github_repository.repos

  repository    = each.value.name
  branch        = "develop"
  source_branch = lookup(each.value, "default_branch", "main")
}

# Set 'develop' as the default branch
resource "github_branch_default" "default" {
  for_each = github_branch.develop

  repository = each.value.repository
  branch     = each.value.branch
}

# Protect the main branch
resource "github_branch_protection" "main" {
  for_each = {
    for k, v in github_repository.repos : k => v if v.visibility == "public"
  }
  repository_id = each.value.node_id
  # repository    = each.value.name
  pattern = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
  }

  required_status_checks {
    strict   = true
    contexts = ["ci/github-actions"]
  }
}

# Add AWS secrets to each repository
resource "github_actions_secret" "aws_access_key_id" {
  for_each = github_repository.repos

  repository      = each.value.name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "aws_secret_access_key" {
  for_each = github_repository.repos

  repository      = each.value.name
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

# Outputs
output "repositories_created" {
  value = {
    for name, repo in github_repository.repos : name => {
      url            = repo.html_url
      ssh_clone_url  = repo.ssh_clone_url
      default_branch = github_branch_default.default[name].branch
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
