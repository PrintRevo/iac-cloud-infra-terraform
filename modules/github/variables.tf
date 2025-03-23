variable "organization" {
  description = "GitHub organization (group) name where repositories will be created"
  type        = string
  default     = "PrintRevo"
}

variable "module_dir" {
  description = "Directory path containing JSON files with repository metadata"
  type        = string
}

variable "auto_init" {
  description = "Automatically initialize repositories with README"
  type        = bool
  default     = true
}

variable "aws_access_key_id" {
  description = "AWS Secret Key ID for GitHub Actions"
  type        = string
  sensitive   = true
}
variable "aws_secret_access_key" {
  description = "AWS Secret Key for GitHub Actions"
  type        = string
  sensitive   = true
}

variable "aws_profile" {
  description = "AWS Profile for GitHub Actions"
  type        = string
  sensitive   = true
}
