# VPC Endpoint for EventBridge to allow Lambda in private subnet to access EventBridge
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
