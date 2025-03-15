# ------------------------------------------------------------------------------
# S3 Bucket for Web Hosting
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.prefix}-${var.environment}-frontend"

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------------------------------------------------------
# CloudFront Origin Access Identity
# ------------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.prefix}-${var.environment} frontend"
}

# ------------------------------------------------------------------------------
# S3 Bucket Policy for CloudFront Access
# ------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# CloudFront Distribution
# ------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.frontend.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.frontend.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
    compress    = true
  }

  # Handle SPA routing - route all paths to index.html
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Use custom domain and SSL certificate if provided
  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      minimum_protocol_version = "TLSv1.2_2021"
      ssl_support_method       = "sni-only"
    }
  }

  # Add aliases if custom domain provided
  dynamic "aliases" {
    for_each = length(var.domain_names) > 0 ? [1] : []
    content {
      names = var.domain_names
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Route53 Records (if domain names provided)
# ------------------------------------------------------------------------------

resource "aws_route53_record" "frontend" {
  count = length(var.domain_names) > 0 && var.zone_id != null ? length(var.domain_names) : 0

  zone_id = var.zone_id
  name    = var.domain_names[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

# ------------------------------------------------------------------------------
# Streamlit Resources
# ------------------------------------------------------------------------------

resource "aws_key_pair" "streamlit_key" {
  count      = var.create_streamlit ? 1 : 0
  key_name   = "${var.prefix}-${var.environment}-streamlit-key"
  public_key = var.ssh_public_key

  tags = var.tags
}

resource "aws_security_group" "streamlit_sg" {
  count       = var.create_streamlit ? 1 : 0
  name        = "${var.prefix}-${var.environment}-streamlit-sg"
  description = "Allow inbound access to Streamlit app"
  vpc_id      = var.vpc_id

  # Allow Streamlit web traffic on port 8501
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
      Name = "${var.prefix}-${var.environment}-streamlit-sg"
    }
  )
}

# IAM Role and Instance Profile for Streamlit
resource "aws_iam_role" "streamlit_role" {
  count = var.create_streamlit ? 1 : 0
  name  = "${var.prefix}-${var.environment}-streamlit-role"

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

  tags = var.tags
}

resource "aws_iam_instance_profile" "streamlit_profile" {
  count = var.create_streamlit ? 1 : 0
  name  = "${var.prefix}-${var.environment}-streamlit-profile"
  role  = aws_iam_role.streamlit_role[0].name
}

# EC2 instance for Streamlit
resource "aws_instance" "streamlit" {
  count = var.create_streamlit ? 1 : 0

  ami                    = var.streamlit_ami_id
  instance_type          = var.streamlit_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.streamlit_sg[0].id]
  iam_instance_profile   = aws_iam_instance_profile.streamlit_profile[0].name
  key_name               = aws_key_pair.streamlit_key[0].key_name

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${var.environment}-streamlit-instance"
    }
  )
}
