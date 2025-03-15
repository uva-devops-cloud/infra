# Compute Module

This module creates the Lambda functions and related resources for the StudentPortal application.

## Resources Created

- Lambda execution IAM role with required permissions
- Lambda functions for CRUD operations on students
- CloudWatch Log Groups for Lambda function logs
- IAM policies for Lambda to access Secrets Manager

## Usage

```terraform
module "compute" {
  source = "../modules/compute"

  prefix                  = "studentportal"
  private_subnet_ids      = [module.networking.private_subnet_id]
  lambda_security_group_id = module.networking.lambda_security_group_id
  lambda_code_bucket      = "my-lambda-code-bucket"
  lambda_code_key_prefix  = "lambda-code/v1"

  # Database connection info
  db_secret_arn  = module.database.db_secret_arn
  db_secret_name = module.database.db_secret_name
  db_name        = module.database.db_name
  db_host        = module.database.db_address
  db_port        = module.database.db_port

  # Optional parameters
  lambda_runtime    = "python3.9"  # default
  lambda_timeout    = 30           # default
  lambda_memory_size = 256         # default
  log_retention_days = 30          # default

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
