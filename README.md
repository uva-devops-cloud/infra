# StudentPortal Infrastructure

This repository contains the infrastructure-as-code for deploying and managing all AWS resources for the StudentPortal project. The infrastructure is defined using Terraform in a modular, environment-based structure.

## Architecture Overview

The infrastructure follows a modular design pattern with clear separation of concerns:

infra/ ├── modules/ # Reusable infrastructure components ├── environments/ # Environment-specific configurations ├── config/ # Backend configuration └── .github/workflows/ # CI/CD pipelines

![Architecture Diagram](https://via.placeholder.com/800x400?text=StudentPortal+Infrastructure+Architecture)

## Modular Structure

### Modules

Each module encapsulates a specific functional component of the infrastructure:

| Module       | Description                                                   |
| ------------ | ------------------------------------------------------------- |
| `networking` | VPC, subnets, route tables, VPC endpoints, security groups    |
| `database`   | RDS PostgreSQL instance, subnet groups, secrets               |
| `compute`    | Lambda functions, IAM roles and policies                      |
| `api`        | HTTP API Gateway, routes, integrations                        |
| `identity`   | Cognito user pools, Google identity provider, JWT authorizers |
| `frontend`   | S3 bucket, CloudFront, Streamlit EC2 instance                 |
| `events`     | EventBridge event bus, rules, targets                         |
| `migrations` | Database migration resources, S3 bucket for scripts           |
| `monitoring` | CloudWatch alarms, dashboards, event rules                    |

### Environments

Environment-specific configurations that use the modules:

- `environments/dev/` - Development environment
- `environments/prod/` - Production environment

## How to Use

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- GitHub Actions permissions for CI/CD

### Local Development

1. Clone this repository: git clone https://github.com/your-org/infra.git cd infra

2. Navigate to the desired environment: cd environments/dev

3. Initialize Terraform: terraform init -backend-config=../../config/backend-dev.config

4. Plan changes: terraform plan -var-file=dev.tfvars

5. Apply changes: terraform plan -var-file=dev.tfvars

## CI/CD Pipeline

The repository includes GitHub Actions workflows that automatically deploy changes:

- Pushes to any branch trigger deployment to the dev environment
- Pushes to `main` or `develop` branches trigger deployment to both dev and prod environments
- Production deployments require approval via GitHub Environments

## Adding a New Environment

1. Create a new directory in the `environments` folder: mkdir -p environments/staging

2. Copy and modify configuration files: cp config/backend-dev.config config/backend-staging.config

3. Update variables and backend configuration as needed

4. Update GitHub workflows to include the new environment

## Module Usage Examples

### Networking Module

```hcl
module "networking" {
  source = "../../modules/networking"

  prefix            = var.prefix
  aws_region        = var.aws_region
  vpc_cidr          = var.vpc_cidr
  availability_zone = var.availability_zone

  tags = local.common_tags
}

API Module

module "api" {
  source = "../../modules/api"

  prefix         = "${var.prefix}-${var.environment}"
  lambda_functions = {
    get_all_students  = module.compute.get_all_students_lambda
    get_student_by_id = module.compute.get_student_by_id_lambda
    create_student    = module.compute.create_student_lambda
    update_student    = module.compute.update_student_lambda
    delete_student    = module.compute.delete_student_lambda
    orchestrator      = module.compute.orchestrator_lambda
    update_profile    = module.compute.update_profile_lambda
  }

  jwt_authorizer_id  = module.identity.jwt_authorizer_id
  cors_allowed_origins = var.api_cors_allowed_origins

  tags = local.common_tags
}

```
