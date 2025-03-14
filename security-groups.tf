# Security group for Lambda functions
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "lambda-sg"
    }
  )
}

# Security group for RDS
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

  tags = merge(
    local.common_tags,
    {
      Name = "rds-postgres-sg"
    }
  )
}

# Security Group Rule for Lambda to VPC Endpoints (outbound)
resource "aws_security_group_rule" "lambda_to_endpoints" {
  security_group_id = aws_security_group.lambda_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"] # VPC CIDR
  description       = "Allow Lambda to access VPC endpoints"
}

# Security Group Rule for VPC Endpoints from Lambda (inbound)
resource "aws_security_group_rule" "endpoint_from_lambda" {
  security_group_id        = aws_security_group.lambda_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow VPC endpoints to receive requests from Lambda"
}
