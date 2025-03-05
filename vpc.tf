resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "studentportal-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }

  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "private-subnet"
  }

  depends_on = [aws_vpc.main]
}

# Allows both inbound and outbound internet traffic for resources in a public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }

  depends_on = [aws_vpc.main]
}

# Elastic IP for NAT Gateway
# resource "aws_eip" "nat" {
#   domain = "vpc"

#   tags = {
#     Name = "nat-eip"
#   }
# }

# Allows only outbound internet traffic for resources in a private subnet
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "nat-gateway"
#   }

#   depends_on = [aws_subnet.public, aws_eip.nat]
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Links public route table to public subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_subnet.public, aws_route_table.public]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }

  depends_on = [aws_vpc.main]
}

# Links private route table to private subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_subnet.private, aws_route_table.private]
}
