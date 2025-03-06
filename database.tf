# ----------------------------------------------------------------------------
# Networking for RDS
# ----------------------------------------------------------------------------

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"  # Use a different CIDR than your existing subnets
  availability_zone = var.availability_zone_b  # Use a second AZ in your chosen region
  
  tags = {
    Name = "private-subnet-b"
  }
  
  depends_on = [aws_vpc.main]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private.id,
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
  version = "~> 5.0"

  identifier         = "student-portal-db"
  engine             = "postgres"
  engine_version     = "14"
  instance_class     = "db.t3.medium"
  allocated_storage  = 20
  db_name               = "studentportal"
  username           = "admin"
  password           = random_password.db_password.result
  multi_az           = false
  availability_zone = var.availability_zone
  publicly_accessible = false

  family             = "postgres14"

  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]
#   subnets = [aws_subnet.private.id, aws_subnet.private_b.id]

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

# ----------------------------------------------------------------------------
# Flyaway migration tool
# ----------------------------------------------------------------------------
resource "null_resource" "db_migrations" {
  depends_on = [module.rds]

  provisioner "local-exec" {
    command = "flyway -url=jdbc:postgresql://${module.rds.db_instance_endpoint}/studentportal -user=admin -password=${random_password.db_password.result} -locations=filesystem:./migrations migrate"
  }
}