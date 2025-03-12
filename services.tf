# Define a simple AWS EventBridge event bus suitable for free tier usage
resource "aws_cloudwatch_event_bus" "main" {
  name = "main-event-bus"

  tags = {
    Name        = "main-event-bus"
    Environment = "dev"
    Tier        = "free"
  }
}
