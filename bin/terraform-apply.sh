#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Apply the Terraform configuration"
terraform apply "tfplan"