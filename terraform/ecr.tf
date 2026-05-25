resource "aws_ecr_repository" "taskflow" {
  name                 = "taskflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "taskflow"
    project = "taskflow"
  }
}

resource "aws_ecr_lifecycle_policy" "taskflow" {
  repository = aws_ecr_repository.taskflow.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}