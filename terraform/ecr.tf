resource "aws_ecr_repository" "diploma-repo" {
  name                 = "${var.entity_name}-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
}
