#!/bin/bash

# Navigate to the Terraform configuration directory
cd /path/to/your/terraform/configuration

# Initialize Terraform
terraform init

# Generate and show the execution plan
terraform plan -out=tfplan

# Optional: Apply the plan
# terraform apply tfplan