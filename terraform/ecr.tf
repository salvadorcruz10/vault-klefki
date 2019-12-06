resource "aws_ecr_repository" "app" {
  name = "${var.service}-${var.environment}"
}
