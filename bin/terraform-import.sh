#!/bin/bash

set -e # Exit on error

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
  #   RESOURCE_TYPE=$(echo "$ARN" | cut -d':' -f3)  # Extract AWS service type
  #   RESOURCE_PATH=$(echo "$ARN" | cut -d':' -f6-)  # Extract resource path
  #   RESOURCE_ID=$(echo "$RESOURCE_PATH" | awk -F'[:/]' '{print $NF}')  # Extract last part of resource ID

  RESOURCE_TYPE=$(echo "$ARN" | sed -E 's/^arn:aws:[^:]+:[^:]+:[0-9]+:([^\/]+).*/\1/')
  RESOURCE_PATH=$(echo "$ARN" | sed -E 's/^arn:aws:[^:]+:[^:]+:[0-9]+://')
  RESOURCE_ID=$(echo "$RESOURCE_PATH" | grep -oE '[^/]+$')

  echo "Identified resource: Type=$RESOURCE_TYPE, ID=$RESOURCE_ID"

  # Determine Terraform resource type dynamically
  case $RESOURCE_TYPE in
  vpc)
    TF_RESOURCE="aws_vpc"
    ;;
  cluster)
    TF_RESOURCE="aws_eks_cluster"
    ;;
  "arn:aws:s3:::printrevo-bucket-$ENVIRONMENT")
    TF_RESOURCE="aws_s3_bucket"
    ;;
  s3)
    TF_RESOURCE="aws_s3_bucket"
    ;;
  sqs)
    TF_RESOURCE="aws_sqs_queue"
    ;;
  "printrevo-event-messages-queue")
    TF_RESOURCE="aws_sqs_queue"
    ;;
  db)
    TF_RESOURCE="aws_db_instance"
    ;;
  "db:printrevo-$ENVIRONMENT-db")
    TF_RESOURCE="aws_db_instance"
    ;;
  subgrp)
    TF_RESOURCE="aws_db_subnet_group"
    ;;
  iam)
    TF_RESOURCE="aws_iam_role"
    ;;
  ec2)
    TF_RESOURCE="aws_instance"
    ;;
  instance)
    TF_RESOURCE="aws_instance"
    ;;
  nodegroup)
    TF_RESOURCE="aws_eks_node_group"
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
  repository)
    TF_RESOURCE="aws_ecr_repository"
    ;;
  *)
    echo "Skipping unsupported resource type: $RESOURCE_TYPE with ID: $RESOURCE_ID"
    continue
    ;;
  esac

  if terraform state list | grep -q "$TF_RESOURCE.$RESOURCE_ID"; then
    echo "Importing $TF_RESOURCE.$RESOURCE_ID...$ARN"
    if terraform import "$TF_RESOURCE.$RESOURCE_ID" "$ARN"; then
      echo "Successfully imported $TF_RESOURCE.$RESOURCE_ID"
    else
      echo "Error importing $TF_RESOURCE.$RESOURCE_ID. Skipping..."
      continue
    fi
    continue
  fi
  sleep 1
  
  # Read JSON files in ./datas/repository-definitions
  for FILE in ./modules/aws/ecr/repositories/*.json; do
    NAME=$(jq -r '.repo_name' "$FILE")
    if terraform state list | grep -q "$NAME"; then
      echo "Resource $NAME already managed by Terraform. Skipping import."
      continue 2
    fi
  done

  # for FILE in ./datas/repository-definitions/*.json; do
  #   NAME=$(jq -r '.name' "$FILE")
  #   if terraform state list | grep "$NAME"; then
  #     echo "Resource $NAME already managed by Terraform. Skipping import."
  #     continue 2
  #   fi
  # done

done

echo "Terraform import completed successfully!"
