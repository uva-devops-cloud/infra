# Networking Module

This module creates the foundational network infrastructure for the Student Portal application.

## Resources Created

- VPC with DNS support enabled
- Public and private subnets in the specified availability zone
- Internet Gateway for public internet access
- Route tables for public and private subnets
- Security groups for Lambda functions, RDS, and optionally Streamlit
- VPC endpoints for AWS services (EventBridge, Secrets Manager, S3)

## Usage

```terraform
module "networking" {
  source = "../modules/networking"

  aws_region         = "eu-west-2"
  vpc_cidr           = "10.0.0.0/16"
  availability_zone  = var.availability_zone
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"

  # Optional parameters
  prefix             = "studentportal" # default
  create_streamlit_sg = true          # default: false

  tags = {
    Project     = "StudentPortal"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```
