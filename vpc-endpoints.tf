# VPC Endpoint for EventBridge (from previous implementation)
resource "aws_vpc_endpoint" "events" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.events"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "events-vpc-endpoint"
    }
  )
}

# VPC Endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "logs-vpc-endpoint"
    }
  )
}

# VPC Endpoint for Lambda
resource "aws_vpc_endpoint" "lambda" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.lambda"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "lambda-vpc-endpoint"
    }
  )
}

# Add the new endpoints below:

# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "secretsmanager-vpc-endpoint"
    }
  )
}

# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = merge(
    local.common_tags,
    {
      Name = "s3-vpc-endpoint"
    }
  )
}
