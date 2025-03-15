# Database Module

This module provisions an RDS PostgreSQL database for the StudentPortal application.

## Resources Created

- Private subnet in a second availability zone
- Database subnet group spanning two AZs
- Random password generation
- AWS Secrets Manager secret for database password
- RDS PostgreSQL database instance

## Usage

```terraform
module "database" {
  source = "../modules/database"

  vpc_id                 = aws_vpc.main.id
  private_subnet_a_id    = aws_subnet.private.id
  private_route_table_id = aws_route_table.private.id
  availability_zone      = var.availability_zone
  availability_zone_b    = var.availability_zone_b
  rds_security_group_id  = aws_security_group.rds_sg.id
  account_id             = data.aws_caller_identity.current.account_id
  environment            = var.environment
  tags                   = local.common_tags

  # Optional parameters
  db_instance_class      = "db.t3.micro" # default
  private_subnet_b_cidr  = "10.0.3.0/24" # default
}
```
