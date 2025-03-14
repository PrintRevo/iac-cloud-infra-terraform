#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Initializing Terraform..."
terraform init 

echo "Validating Terraform configuration..."
terraform validate


echo "Creating execution plan..."
terraform plan -out=tfplan

# Apply the Terraform configuration
# terraform apply -auto-approve


      # # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
      # - name: Terraform Init
      #   run: terraform init

      # # Checks that all Terraform configuration files adhere to a canonical format
      # - name: Terraform Format
      #   run: terraform fmt -check

      #   # Plan the changes required to reach the desired state of the configuration
      # - name: Terraform Plan
      #   run: terraform plan -out=tfplan -var aws_profile=printrevo-aws-profile -var rds_password=aGVsbG8td29yZA==

      #   # On push to "main", build or change infrastructure according to Terraform configuration files
      #   # Note: It is recommended to set up a required "strict" status check in your repository for "Terraform Cloud". See the documentation on "strict" required status checks for more information: https://help.github.com/en/github/administering-a-repository/types-of-required-status-checks
      # - name: Terraform Apply
      #   run: terraform apply "tfplan"