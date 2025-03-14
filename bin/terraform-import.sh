#!/bin/bash

set -e  # Exit on error

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
  echo "Error: Environment variable not provided."
  echo "Usage: ./terraform-import.sh <environment>"
  exit 1
fi

echo "Fetching AWS resources tagged with Environment=$ENVIRONMENT..."

# Fetch resource ARNs tagged with the specified environment
RESOURCE_ARNS=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=$ENVIRONMENT --output json | jq -r '.ResourceTagMappingList[].ResourceARN')

if [ -z "$RESOURCE_ARNS" ]; then
  echo "No resources found for Environment=$ENVIRONMENT"
  exit 0
fi

echo "Importing resources into Terraform..."

# Loop through each existing ARN and import it into Terraform
for ARN in $RESOURCE_ARNS; do
  RESOURCE_TYPE=$(echo "$ARN" | cut -d':' -f3)  # Extract AWS service type
  RESOURCE_PATH=$(echo "$ARN" | cut -d':' -f6-)  # Extract resource path
  RESOURCE_ID=$(echo "$RESOURCE_PATH" | awk -F'[:/]' '{print $NF}')  # Extract last part of resource ID

  echo "Identified resource: Type=$RESOURCE_TYPE, ID=$RESOURCE_ID"

  # Determine Terraform resource type dynamically
  case $RESOURCE_TYPE in
#     ecs)
      # TF_RESOURCE="aws_ecs_cluster"
      ;;
#     s3)
      # TF_RESOURCE="aws_s3_bucket"
      # ;;
#     sqs)
#       TF_RESOURCE="aws_sqs_queue"
#       ;;
#     rds)
      TF_RESOURCE="aws_db_instance"
      ;;
    ecr)
      TF_RESOURCE="aws_ecr_repository"
      ;;
    iam)
      TF_RESOURCE="aws_iam_role"
      ;;
#     ec2)
      # TF_RESOURCE="aws_instance"
      # ;;
    vpc)
      TF_RESOURCE="aws_vpc"
      ;;
    subnet)
      TF_RESOURCE="aws_subnet"
      ;;
    security-group)
      TF_RESOURCE="aws_security_group"
      ;;
    route-table)
      TF_RESOURCE="aws_route_table"
      ;;
    internet-gateway)
      TF_RESOURCE="aws_internet_gateway"
      ;;
    *)
      echo "Skipping unsupported resource type: $RESOURCE_TYPE"
      continue
      ;;
  esac

  echo "Checking if $TF_RESOURCE.$RESOURCE_ID already exists in Terraform state..."

  if terraform state list | grep -q "$TF_RESOURCE.$RESOURCE_ID"; then
    echo "Resource $TF_RESOURCE.$RESOURCE_ID already managed by Terraform. Skipping import."
    continue
  fi


  echo "Importing $TF_RESOURCE.$RESOURCE_ID..."
 if terraform import "$TF_RESOURCE.$RESOURCE_ID" "$ARN"; then
    echo "Successfully imported $TF_RESOURCE.$RESOURCE_ID"
  else
    echo "Error importing $TF_RESOURCE.$RESOURCE_ID. Skipping..."
  fi
done

echo "Terraform import completed successfully!"
