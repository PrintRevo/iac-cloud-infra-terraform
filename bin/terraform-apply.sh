#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Initializing Terraform..."
terraform init 

echo "Validating Terraform configuration..."
terraform validate

# Apply the Terraform configuration
terraform apply -auto-approve