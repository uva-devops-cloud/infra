output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "db_address" {
  description = "RDS instance address"
  value       = module.rds.db_instance_address
}

output "db_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "Name of the database"
  value       = "studentportal"
}

output "db_username" {
  description = "Database admin username"
  value       = "dbadmin"
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "db_secret_name" {
  description = "Name of the database password secret"
  value       = aws_secretsmanager_secret.db_secret.name
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.db_subnet_group.name
}

output "private_subnet_b_id" {
  description = "ID of the second private subnet created for the database"
  value       = aws_subnet.private_b.id
}

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = module.rds.db_instance_id
}
