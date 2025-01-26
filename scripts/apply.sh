#!/bin/bash

# Navigate to the Terraform directory
cd ../

# Initialize Terraform
terraform init

# Apply the Terraform configuration
terraform apply -auto-approve