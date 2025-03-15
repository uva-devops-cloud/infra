output "bucket_name" {
  description = "Name of the S3 bucket for frontend assets"
  value       = aws_s3_bucket.frontend.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket for frontend assets"
  value       = aws_s3_bucket.frontend.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "website_url" {
  description = "URL of the website (CloudFront distribution URL)"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "custom_domain_urls" {
  description = "URLs of custom domains (if provided)"
  value       = [for name in var.domain_names : "https://${name}"]
}

output "streamlit_instance_id" {
  description = "ID of the Streamlit EC2 instance (if created)"
  value       = var.create_streamlit ? aws_instance.streamlit[0].id : null
}

output "streamlit_public_ip" {
  description = "Public IP of the Streamlit EC2 instance (if created)"
  value       = var.create_streamlit ? aws_instance.streamlit[0].public_ip : null
}

output "streamlit_url" {
  description = "URL to access the Streamlit app (after manual configuration)"
  value       = var.create_streamlit ? "http://${aws_instance.streamlit[0].public_ip}:8501" : null
}

output "streamlit_security_group_id" {
  description = "ID of the Streamlit security group (if created)"
  value       = var.create_streamlit ? aws_security_group.streamlit_sg[0].id : null
}
