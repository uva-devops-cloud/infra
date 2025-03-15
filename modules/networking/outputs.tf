output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "lambda_security_group_id" {
  description = "ID of the Lambda security group"
  value       = aws_security_group.lambda_sg.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

output "streamlit_security_group_id" {
  description = "ID of the Streamlit security group"
  value       = var.create_streamlit_sg ? aws_security_group.streamlit_sg[0].id : null
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "vpc_endpoints" {
  description = "Map of VPC endpoint details"
  value = {
    events = {
      id  = aws_vpc_endpoint.events.id
      dns = aws_vpc_endpoint.events.dns_entry
    }
    secretsmanager = {
      id  = aws_vpc_endpoint.secretsmanager.id
      dns = aws_vpc_endpoint.secretsmanager.dns_entry
    }
    s3 = {
      id = aws_vpc_endpoint.s3.id
    }
  }
}

output "secretsmanager_endpoint_id" {
  description = "ID of the SecretsManager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "secretsmanager_endpoint_dns" {
  description = "DNS entries for the SecretsManager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.dns_entry
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the VPC endpoint security group"
  value       = aws_security_group.vpc_endpoint_sg.id
}
