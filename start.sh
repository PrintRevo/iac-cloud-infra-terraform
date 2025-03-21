#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

AWS_REGION="eu-central-1"
S3_BUCKET="printrevo-terraform-state"
DYNAMODB_TABLE="printrevo-terraform-lock-table"
AWS_PROFILE="default"

# Ensure S3 bucket for Terraform state exists
if ! aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
  if [ "$AWS_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket "$S3_BUCKET"
  else
    aws s3api create-bucket --bucket "$S3_BUCKET" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
  echo "S3 bucket $S3_BUCKET created."
else
  echo "S3 bucket $S3_BUCKET already exists."
fi

# Create DynamoDB Table for Terraform Locking
aws dynamodb create-table \
  --table-name "$DYNAMODB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$AWS_REGION" || echo "DynamoDB table already exists."

# Setup Terraform
terraform_version="1.5.0"
if ! terraform version | grep -q "$terraform_version"; then
  echo "Terraform $terraform_version is required. Install it if not already installed."
fi

# Initialize Terraform Backend (S3)
terraform init -reconfigure

# Retrieve environment variables from AWS Parameter Store
DB_PASSWORD=$(aws ssm get-parameter --name "rds_password" --with-decryption --query "Parameter.Value" --output text)
export DB_PASSWORD

echo "DB_PASSWORD retrieved successfully."

# Terraform Format
terraform fmt -check

# Terraform Validate
terraform validate

# Set execute permission for the import script
chmod +x ./bin/terraform-import.sh

# Import AWS Services by Environment Tag
./bin/terraform-import.sh dev || echo "Import script failed but continuing..."

# Terraform Plan
terraform plan -out=tfplan -var aws_profile="$AWS_PROFILE" -var rds_password="$DB_PASSWORD"

# Set execute permission for the apply script
chmod +x ./bin/terraform-apply.sh

# Run Terraform Apply
./bin/terraform-apply.sh
