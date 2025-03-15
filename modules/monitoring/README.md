# Monitoring Module

This module creates monitoring and alerting resources for the StudentPortal application.

## Resources Created

- CloudWatch Dashboard with metrics for API Gateway, Lambda, and RDS
- CloudWatch Alarms for API errors, Lambda errors, and RDS CPU utilization
- Optional SNS Topic for alarm notifications
- Optional EventBridge rule for scheduled health checks

## Usage

```terraform
module "monitoring" {
  source = "../modules/monitoring"

  prefix      = "studentportal"
  environment = "dev"
  aws_region  = "eu-west-2"

  # API Gateway monitoring
  api_id                  = module.api.api_id
  api_5xx_error_threshold = 5 # default

  # Lambda monitoring
  lambda_function_names  = [
    module.compute.lambda_functions.get_all_students.name,
    module.compute.lambda_functions.get_student_by_id.name,
    module.compute.lambda_functions.create_student.name,
    module.compute.lambda_functions.update_student.name,
    module.compute.lambda_functions.delete_student.name
  ]
  lambda_error_threshold = 1 # default

  # RDS monitoring
  db_instance_id    = module.rds.db_instance_id
  rds_cpu_threshold = 80 # default

  # Notifications
  create_sns_topic     = true
  email_notifications  = ["admin@example.com"]

  # Health check (optional)
  create_health_check_rule = true
  health_check_schedule    = "rate(5 minutes)" # default
  health_check_lambda_arn  = module.health_check.lambda_arn # if you have a health check Lambda
  health_check_lambda_name = module.health_check.lambda_name

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
