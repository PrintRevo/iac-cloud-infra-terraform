provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "github" {
  # Token can be set via GITHUB_TOKEN environment variable
}

# provider "digitalocean" {
#   token = var.do_token
# }
