# API Module

This module creates API Gateway resources for the StudentPortal application.

## Resources Created

- HTTP API Gateway with CORS configuration
- API Gateway stage with logging
- API routes for student CRUD operations
- Lambda integrations for each route
- Lambda permissions to allow API Gateway invocations
- CloudWatch Log Group for API Gateway logs

## Usage

```terraform
module "api" {
  source = "../modules/api"

  prefix = "studentportal"

  # Lambda functions from compute module
  lambda_functions = module.compute.lambda_functions

  # Optional parameters
  api_stage_name = "v1"  # default
  cors_allow_origins = ["https://example.com", "http://localhost:3000"] # default: ["*"]
  log_retention_days = 30 # default

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
