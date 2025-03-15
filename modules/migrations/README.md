# Database Migrations Module

This module creates resources for managing database migrations for the StudentPortal application.

## Resources Created

- S3 bucket for storing migration scripts
- Lambda function for executing migrations
- IAM roles and policies for Lambda execution
- CloudWatch Log group for Lambda logs
- S3 bucket notification to trigger Lambda automatically (optional)

## How It Works

1. Upload SQL migration scripts to the S3 bucket in the `scripts/` folder
2. The Lambda function will be triggered automatically (if enabled) or can be invoked manually
3. The Lambda connects to the database using credentials from Secrets Manager
4. It executes the SQL scripts in alphanumeric order
5. Results are recorded in CloudWatch Logs

## Usage

```terraform
module "migrations" {
  source = "../modules/migrations"

  prefix      = "studentportal"
  environment = "dev"

  # Lambda code location
  lambda_code_bucket    = module.compute.lambda_code_bucket
  lambda_code_key_prefix = "migrations"

  # Database configuration
  db_secret_arn = module.database.db_secret_arn
  db_name       = module.database.db_name

  # VPC configuration (required to access private RDS)
  vpc_config = {
    subnet_ids         = [module.networking.private_subnet_id]
    security_group_ids = [module.networking.lambda_security_group_id]
  }

  # Optional configuration
  lambda_memory_size = 256
  lambda_timeout     = 120
  enable_s3_trigger  = true

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
