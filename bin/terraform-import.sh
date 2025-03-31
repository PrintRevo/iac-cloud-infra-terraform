#!/bin/bash

set -e # Exit on error

ENVIRONMENT=$1
AWS_PROFILE=$2
GITHUB_TOKEN=$3
AWS_REGION=$4
AWS_ACCESS_KEY_ID=$5
AWS_SECRET_ACCESS_KEY=$6
DB_PASSWORD=$7

if [ -z "$ENVIRONMENT" ]; then
  echo "Error: Environment variable not provided."
  echo "Usage: ./terraform-import.sh <environment>"
  exit 1
fi

echo "Fetching AWS resources tagged with Environment=$ENVIRONMENT..."
# Fetch resource ARNs tagged with the specified environment
RESOURCE_ARNS=$(aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=$ENVIRONMENT --output json | jq -r '.ResourceTagMappingList[].ResourceARN')
echo "Debug: RESOURCE_ARNS=$RESOURCE_ARNS"
if [ -z "$RESOURCE_ARNS" ]; then
  echo "No resources found for Environment=$ENVIRONMENT"
  exit 0
fi

# Set AWS credentials and other variables for Terraform
export TF_VAR_aws_profile="$AWS_PROFILE"
export TF_VAR_github_token="$GITHUB_TOKEN"
export TF_VAR_aws_region="$AWS_REGION"
export TF_VAR_aws_access_key_id="$AWS_ACCESS_KEY_ID"
export TF_VAR_aws_access_secret_key="$AWS_SECRET_ACCESS_KEY"
export TF_VAR_rds_password="$DB_PASSWORD"
export TF_VAR_environment="$ENVIRONMENT"

echo "Importing resources into Terraform..."

# Read JSON files in ./datas/repository-definitions
for FILE in ./modules/aws/ecr/repositories/*.json; do
  NAME=$(jq -r '.repo_name' "$FILE")
  if terraform state list | grep "$NAME"; then
    echo "Resource $NAME already managed by Terraform. Skipping import."
    continue
  fi
  ECR_RESOURCE_ID=$(aws ecr describe-repositories --repository-names "$NAME" --query 'repositories[0].repositoryArn' --output text 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch ECR resource ID for $NAME. Skipping..."
    continue
  fi
  echo "Importing ECR $NAME. Importing to ensure consistency...$ECR_RESOURCE_ID"
  terraform import "module.ecr_repositories.aws_ecr_repository.ecr_repos[\"$NAME\"]" "$ECR_RESOURCE_ID"
done

# Read GitHub repository definitions from JSON files
# for FILE in ./modules/github/repositories/*.json; do
#   NAME=$(jq -r '.name' "$FILE")
#   if terraform state list | grep -q "module.github_repositories.github_repository.github_repos[\"$NAME\"]"; then
#     echo "Resource $NAME already managed by Terraform. Skipping import."
#     continue
#   fi
#   GITHUB_RESOURCE_ID=$(gh api repos/:owner/:repo --jq '.id' --header "Authorization: token $GITHUB_TOKEN" --raw-field owner=$(jq -r '.owner' "$FILE") --raw-field repo="$NAME")
#   echo "Importing GitHub repository $NAME with ID $GITHUB_RESOURCE_ID..."

#   # Ensure the resource configuration exists in Terraform before importing
#   if ! grep -q "github_repository \"$NAME\"" ./modules/github/repositories/main.tf; then
#     echo "Error: Resource configuration for $NAME does not exist in Terraform. Please add it before importing."
#     continue
#   fi

#   terraform import "module.github_repositories.github_repository.github_repos[\"$NAME\"]" "$GITHUB_RESOURCE_ID"
# done

# Loop through each existing ARN and import it into Terraform
for ARN in $RESOURCE_ARNS; do

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
  s3 | "arn:aws:s3:::printrevo-bucket-$ENVIRONMENT")
    TF_RESOURCE="aws_s3_bucket"
    ;;
  sqs)
    TF_RESOURCE="aws_sqs_queue"
    ;;
  "printrevo-event-messages-queue")
    TF_RESOURCE="aws_sqs_queue"
    ;;
  db | "db:printrevo-$ENVIRONMENT-db")
    TF_RESOURCE="aws_db_instance"
    ;;
  subgrp)
    TF_RESOURCE="aws_db_subnet_group"
    ;;
  iam)
    TF_RESOURCE="aws_iam_role"
    ;;
  ec2 | instance)
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
  *)
    echo "Skipping unsupported resource type: $RESOURCE_TYPE with ID: $RESOURCE_ID"
    continue
    ;;
  esac
  echo "Found: $RESOURCE_TYPE with ID: $RESOURCE_ID"

  TF_STATES=$(terraform state list | grep "$TF_RESOURCE")
  echo $TF_STATES
  if [ -n "$TF_STATES" ]; then
    IFS=$'\n' read -rd '' -a TF_STATE_ARRAY <<<"$TF_STATES"
    echo "Matching Terraform states found for $TF_RESOURCE: ${TF_STATE_ARRAY[@]}"
    # for TF_STATE in "${TF_STATE_ARRAY[@]}"; do
    #   echo "Importing.... $TF_STATE with ID $RESOURCE_ID"
    #   # Uncomment the following block to enable actual import
    #   if terraform import $TF_STATE $RESOURCE_ID; then
    #     echo "Successfully imported $TF_RESOURCE.$RESOURCE_ID"
    #   else
    #     echo "Error importing $TF_STATE. Skipping..."
    #   fi
    # done
  else
    echo "No matching state found for $TF_RESOURCE. Skipping import."
  fi

done

echo "Terraform import completed successfully!"
