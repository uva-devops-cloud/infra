# Events Module

This module creates EventBridge resources for the event-driven architecture of the StudentPortal application.

## Resources Created

- EventBridge Event Bus
- Event Rules for different student queries and operations
- Event Targets connecting rules to Lambda functions
- Lambda permissions for EventBridge invocation
- Optional VPC Endpoint for EventBridge (with security group)

## Usage

```terraform
module "events" {
  source = "../modules/events"

  prefix      = "studentportal"
  environment = "dev"
  aws_region  = "eu-west-2"

  # Lambda function ARNs from compute module
  orchestrator_lambda_arn  = module.compute.orchestrator_lambda_arn
  orchestrator_lambda_name = module.compute.orchestrator_lambda_name

  student_data_lambda_arn  = module.compute.student_data_lambda_arn
  student_data_lambda_name = module.compute.student_data_lambda_name

  student_courses_lambda_arn  = module.compute.student_courses_lambda_arn
  student_courses_lambda_name = module.compute.student_courses_lambda_name

  update_profile_lambda_arn  = module.compute.update_profile_lambda_arn
  update_profile_lambda_name = module.compute.update_profile_lambda_name

  # Optional VPC endpoint configuration
  create_vpc_endpoint = true
  vpc_id              = module.networking.vpc_id
  vpc_cidr            = module.networking.vpc_cidr
  private_subnet_ids  = [module.networking.private_subnet_id]

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
