terraform {
  backend "s3" {
    bucket         = "printrevo-terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "printrevo-terraform-lock-table"
  }
}
