resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "studentportal-frontend-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.frontend_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.frontend_bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = "yj2nmxb5j7.execute-api.eu-west-2.amazonaws.com"
    origin_id   = "API-Gateway-Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "StudentPortal Frontend CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["HEAD", "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"] # Added HEAD
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "API-Gateway-Origin"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend_identity" {
  comment = "Origin Access Identity for StudentPortal Frontend CloudFront Distribution"
}
