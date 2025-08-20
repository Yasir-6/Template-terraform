
# AWS Infrastructure with Terraform

This repository contains Terraform configurations for deploying a complete AWS infrastructure including VPC, Aurora, ALB, ECR, and ECS resources.

## Infrastructure Components

### Backend Infrastructure
- S3 Bucket for Terraform state storage
- DynamoDB table for state locking

### Core Infrastructure Components
1. **VPC Module**
   - Custom VPC
   - Public and Private Subnets
   - Internet Gateway
   - NAT Gateway
   - Route Tables

2. **Application Load Balancer (ALB) Module**
   - Application Load Balancer
   - Target Groups
   - Security Group
   - Listeners

3. **Elastic Container Service (ECS) Module**
   - ECS Cluster
   - ECS Service
   - Task Definition
   - IAM Roles and Policies
   - Security Groups

## Directory Structure
```
.
├── .github
│   └── workflows
│       ├── terraform-deploy.yml
│       └── terraform-destroy.yml
└── infra
    ├── environments
    │   ├── backend
    │   │   └── main.tf
    │   └── dev
    │       ├── alb
    │       │   ├── main.tf
    │       │   ├── terraform.tfvars
    │       │   └── variables.tf
    │       ├── ecs
    │       │   ├── main.tf
    │       │   ├── terraform.tfvars
    │       │   └── variables.tf
    │       └── vpc
    │           └── main.tf
    └── modules
        ├── alb
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── ecs
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── vpc
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
```

## Deployment Order

### Creation Order (terraform-deploy.yml)
1. Backend Infrastructure (S3 + DynamoDB)
2. VPC (Network Foundation)
3. ALB (Load Balancer)
4. ECS (Container Service)

### Deletion Order (terraform-destroy.yml)
1. ECS (Container Service)
2. ALB (Load Balancer)
3. VPC (Network Foundation)
4. Backend Infrastructure (if explicitly confirmed)

## Required AWS Permissions

The following AWS managed policies are required for deployment:
- AmazonVPCFullAccess
- AmazonECS_FullAccess
- AmazonS3FullAccess
- AmazonDynamoDBFullAccess
- ElasticLoadBalancingFullAccess
- IAMFullAccess

## GitHub Secrets Required

The following secrets need to be configured in GitHub:
- `AWS_ACCESS_KEY_ID`: AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key

## Environment Configuration

The infrastructure is configured for the following environments:
- dev (default)
- staging (configurable)
- prod (configurable)

## AWS Region

All resources are deployed in the `us-east-2` region.

## State Management

Terraform state is managed remotely with:
- **Backend**: S3 bucket
- **State Locking**: DynamoDB table
- **Bucket Name**: terraformfilesremotestate
- **DynamoDB Table**: terraform-state-lock

## Deployment

### Manual Deployment
Infrastructure can be deployed manually using GitHub Actions workflow:
1. Go to Actions tab
2. Select "Deploy AWS Infrastructure"
3. Click "Run workflow"
4. Select environment (dev/staging/prod)
5. Run the workflow

### Destruction
Infrastructure can be destroyed using GitHub Actions workflow:
1. Go to Actions tab
2. Select "Destroy AWS Infrastructure"
3. Click "Run workflow"
4. Select environment
5. Type "DESTROY" to confirm
6. Run the workflow

## Security Notes

- All sensitive information is stored in GitHub Secrets
- Each component uses dedicated security groups
- Network isolation is maintained through proper subnet configuration
- Database credentials are managed through AWS Secrets Manager
