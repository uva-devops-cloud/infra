resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-unique-bucket-name"
  acl    = "private"
}

resource "aws_cloudformation_stack" "frontend_stack" {
  name         = "frontend-cloudformation-stack"
  template_body = <<TEMPLATE
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "FrontendBucket": {
      "Type": "AWS::S3::Bucket",
      "Properties": {
        "BucketName": "${aws_s3_bucket.frontend_bucket.bucket}"
      }
    }
  }
}
TEMPLATE
}