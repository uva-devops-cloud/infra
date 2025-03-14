# ----------------------------------------------------------------------------
# Networking for RDS
# ----------------------------------------------------------------------------

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"           # Use a different CIDR than your existing subnets
  availability_zone = var.availability_zone_b # Use a second AZ in your chosen region

  tags = {
    Name = "private-subnet-b"
  }

  depends_on = [aws_vpc.main]

}

# Add missing route table association for private_b
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_subnet.private_b, aws_route_table.private]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_b.id
  ]

  depends_on = [aws_subnet.private, aws_subnet.private_b]

  tags = merge(
    local.common_tags,
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
  name        = "studentportal-db-password-${data.aws_caller_identity.current.account_id}"
  description = "RDS PostgreSQL master password for StudentPortal"

  tags = local.common_tags
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
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "studentportal"
  username            = "dbadmin"
  password            = random_password.db_password.result
  multi_az            = false
  availability_zone   = var.availability_zone
  publicly_accessible = false

  family = "postgres14"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  #   subnets = [aws_subnet.private.id, aws_subnet.private_b.id]

  # Snapshots/backups
  skip_final_snapshot     = false
  backup_retention_period = 0

  storage_encrypted = true

  tags = local.common_tags

  depends_on = [
    aws_db_subnet_group.db_subnet_group,
    aws_security_group.rds_sg,
    random_password.db_password
  ]
}
