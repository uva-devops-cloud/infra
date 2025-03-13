resource "aws_security_group" "streamlit_sg" {
  name        = "studentportal-streamlit-sg"
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

  tags = {
    Name = "streamlit-security-group"
  }
}

# EC2 instance for the Streamlit app (minimal configuration)
resource "aws_instance" "streamlit" {
  ami                    = "ami-0eb260c4d5475b901"  # Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.streamlit_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.streamlit_profile.name
  key_name               = aws_key_pair.ec2_access_key.key_name  # Reference the key pair here

  tags = {
    Name = "streamlit-instance"
  }
}

# IAM Role and Instance Profile for EC2
resource "aws_iam_role" "streamlit_role" {
  name = "streamlit-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "streamlit_profile" {
  name = "streamlit-app-profile"
  role = aws_iam_role.streamlit_role.name
}

# Output the public IP for SSH access
output "streamlit_instance_ip" {
  value       = aws_instance.streamlit.public_ip
  description = "Public IP of the Streamlit EC2 instance"
}

# Output the future Streamlit URL for reference
output "streamlit_url" {
  value       = "http://${aws_instance.streamlit.public_ip}:8501"
  description = "URL to access the Streamlit app (after manual configuration)"
}
