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

# Loop through each resource ARN and import it into Terraform
for ARN in $RESOURCE_ARNS; do
  RESOURCE_TYPE=$(echo "$ARN" | cut -d':' -f3)  # Extract AWS service type
  RESOURCE_ID=$(echo "$ARN" | awk -F'/' '{print $NF}')  # Extract resource ID

  case $RESOURCE_TYPE in
    ec2)
      TF_RESOURCE="aws_instance"
      ;;
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
    ecs-cluster)
      TF_RESOURCE="aws_ecs_cluster"
      ;;
    s3-bucket)
      TF_RESOURCE="aws_s3_bucket"
      ;;
    sqs-queue)
      TF_RESOURCE="aws_sqs_queue"
      ;;
    db-instance)
      TF_RESOURCE="aws_db_instance"
      ;;
    ecr-repository)
      TF_RESOURCE="aws_ecr_repository"
      ;;
    iam-role)
      TF_RESOURCE="aws_iam_role"
      ;;
    *)
      echo "Skipping unsupported resource type: $RESOURCE_TYPE"
      continue
      ;;
  esac

  echo "Importing $TF_RESOURCE.$RESOURCE_ID..."
  terraform import "$TF_RESOURCE.$RESOURCE_ID" "$ARN"
done

echo "Terraform import completed successfully!"
