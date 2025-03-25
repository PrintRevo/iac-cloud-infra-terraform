# Project Overview

This project is designed to provision AWS resources using Terraform. It includes modules for creating a Virtual Private Cloud (VPC), Elastic Container Registry (ECR), Elastic Container Service (ECS), storage services, and an Elastic Kubernetes Service (EKS) cluster utilizing free tier resources.

## Project Structure

```
iac-terraform
├── main.tf                # Main configuration file for Terraform
├── modules
│   ├── aws
│   │   ├── vpc            # Module for creating a Virtual Private Cloud (VPC)
│   │   ├── ecr            # Module for creating Elastic Container Registry (ECR) resources
│   │   ├── ecs            # Module for creating Elastic Container Service (ECS) resources
│   │   ├── storages       # Module for creating storage resources
│   │   └── eks            # Module for creating an Elastic Kubernetes Service (EKS) cluster
│   │       ├── main.tf    # Defines resources for the EKS cluster
│   │       ├── variables.tf # Input variables for the EKS module
│   │       └── outputs.tf  # Outputs for the EKS module
├── variables.tf           # Input variables for the overall Terraform configuration
├── outputs.tf             # Outputs for the overall Terraform configuration
└── README.md              # Documentation for the project
```

## Getting Started

### Prerequisites

- Terraform installed on your machine.
- AWS account with appropriate permissions to create resources.

### Setup Instructions

1. Clone the repository to your local machine.
2. Navigate to the project directory:
   ```
   cd iac-terraform
   ```
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Review the configuration:
   ```
   terraform plan
   ```
5. Apply the configuration to create the resources:
   ```
   terraform apply
   ```

### Modules

- **VPC Module**: Creates a VPC with public and private subnets.
- **ECR Module**: Sets up an Elastic Container Registry for storing Docker images.
- **ECS Module**: Configures an Elastic Container Service for running containerized applications.
- **Storage Module**: Creates necessary storage resources.
- **EKS Module**: Provisions an Elastic Kubernetes Service cluster using free tier resources.

### Outputs

After applying the configuration, you will receive outputs that include:

- VPC ID
- ECR repository URLs
- ECS cluster details
- EKS cluster endpoint and node group information

### Cleanup

To remove all resources created by Terraform, run:
```
terraform destroy
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.