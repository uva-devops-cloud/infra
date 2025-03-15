# ------------------------------------------------------------------------------
# VPC and Primary Network Infrastructure
# ------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpc"
    }
  )
}

# ------------------------------------------------------------------------------
# Public Subnet and Routing
# ------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-public-subnet"
    }
  )
}

# Allows both inbound and outbound internet traffic for resources in a public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-igw"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-public-route-table"
    }
  )
}

# Links public route table to public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------------------------
# Private Subnet and Routing
# ------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-private-subnet"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-private-route-table"
    }
  )
}

# Links private route table to private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ------------------------------------------------------------------------------
# VPC Endpoints
# ------------------------------------------------------------------------------

# VPC Endpoint for EventBridge
resource "aws_vpc_endpoint" "events" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.events"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "events-vpc-endpoint"
    }
  )
}

# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
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
    var.tags,
    {
      Name = "${var.prefix}-s3-endpoint"
    }
  )
}

# Shared security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {

  name        = "${var.prefix}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpc-endpoint-sg"
    }
  )
}

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------

# Security group for Lambda functions
resource "aws_security_group" "lambda_sg" {
  name        = "${var.prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-lambda-sg"
    }
  )
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.prefix}-rds-postgres-sg"
  description = "Allow inbound Postgres traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-rds-postgres-sg"
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
  cidr_blocks       = [var.vpc_cidr]
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

# Security group for Streamlit
resource "aws_security_group" "streamlit_sg" {
  name        = "${var.prefix}-streamlit-sg"
  description = "Allow inbound access to Streamlit app"
  vpc_id      = aws_vpc.main.id

  # Allow Streamlit web traffic on port 8501
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access for your manual configuration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to your IP
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-streamlit-sg"
    }
  )
}
