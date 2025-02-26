provider "aws" {
  region = "eu-north-1"
}

# Create an S3 Bucket (for Terraform state storage)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-bucket"
  acl    = "private"
}

# DynamoDB for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# AWS Cognito User Pool
resource "aws_cognito_user_pool" "students" {
  name = "students-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
    require_lowercase = true
  }
}

# API Gateway (for Lambda endpoints)
resource "aws_apigatewayv2_api" "api" {
  name          = "students-api"
  protocol_type = "HTTP"
}

# ----------------------------------------------------------------------------
# Networking for RDS
# ----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow inbound Postgres traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# ----------------------------------------------------------------------------
# Secrets Manager + Random Password
# ----------------------------------------------------------------------------

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "rds-db-password"
  description = "RDS PostgreSQL master password"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result
}

# ----------------------------------------------------------------------------
# RDS Module
# ----------------------------------------------------------------------------

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier         = "student-portal-db"
  engine             = "postgres"
  engine_version     = "14"
  instance_class     = "db.t3.medium"
  allocated_storage  = 20
  name               = "studentportal"
  username           = "admin"
  password           = random_password.db_password.result
  multi_az           = true
  publicly_accessible = false

  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]
  subnets                 = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  # Snapshots/backups
  skip_final_snapshot     = false
  backup_retention_period = 7

  storage_encrypted       = true

  tags = {
    Project = "student-portal"
    Env     = "prod"
  }
}

# ----------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}