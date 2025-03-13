

# EventBridge rules for the student query system

# EventBridge rule for student degree queries
resource "aws_cloudwatch_event_rule" "get_student_degree_rule" {
  name           = "get-student-degree-rule"
  description    = "Rule to trigger get-student-degree lambda"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["student.query.orchestrator"],
    detail_type = ["GetStudentCurrentDegree"],
  })

  depends_on = [aws_cloudwatch_event_bus.main]

  tags = local.common_tags
}

# Rule targets and other rules here...
