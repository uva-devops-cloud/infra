resource "aws_resourceexplorer2_index" "explorer_index" {
  type = "LOCAL"
  tags = local.common_tags
}

resource "aws_resourceexplorer2_view" "explorer_view" {
  name       = "students-infra-view"
  depends_on = [aws_resourceexplorer2_index.explorer_index]
  tags       = local.common_tags
}
