# ----------------------------------------------------------------------------
# Networking for RDS
# ----------------------------------------------------------------------------

resource "aws_subnet" "private_b" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zone_b

  tags = merge(
    var.tags,
    {
      Name = "private-subnet-b"
    }
  )
}

# Add missing route table association for private_b
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = var.private_route_table_id

  depends_on = [aws_subnet.private_b]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    var.private_subnet_a_id,
    aws_subnet.private_b.id
  ]

  tags = merge(
    var.tags,
    {
      Name = "rds-subnet-group"
    }
  )
}

# ----------------------------------------------------------------------------
# Secrets Manager + Random Password
# ----------------------------------------------------------------------------

resource "random_password" "db_password" {
  length  = 16
  special = true

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "studentportal-db-password-${var.account_id}"
  description = "RDS PostgreSQL master password for StudentPortal"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result

  depends_on = [aws_secretsmanager_secret.db_secret, random_password.db_password]
}

# ----------------------------------------------------------------------------
# RDS Module
# ----------------------------------------------------------------------------

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier          = "student-portal-db"
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = var.db_instance_class
  allocated_storage   = 20
  db_name             = "studentportal"
  username            = "dbadmin"
  password            = random_password.db_password.result
  multi_az            = false
  availability_zone   = var.availability_zone
  publicly_accessible = false

  family = "postgres14"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_security_group_id]

  # Snapshots/backups
  skip_final_snapshot     = var.environment == "dev" ? true : false
  backup_retention_period = var.environment == "dev" ? 0 : 7

  storage_encrypted = true

  tags = var.tags
}
