# Contains common local variables used across the infrastructure

locals {
  common_tags = {
    Project     = "Student Query System"
    Environment = var.environment
    Terraform   = "True"
  }

  # Database configuration
  db_host = "student-db.cluster-xyz.eu-west-2.rds.amazonaws.com"
  db_name = "student_data"
  db_port = 5432

  # VPC and networking
  private_subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_b.id,
  ]

}
