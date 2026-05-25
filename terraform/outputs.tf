output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.taskflow_eks_cluster.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.taskflow_eks_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = aws_eks_cluster.taskflow_eks_cluster.certificate_authority[0].data
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker image pushes"
  value       = aws_ecr_repository.taskflow.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC — paste this into your workflow"
  value       = aws_iam_role.github_actions.arn
}

output "aws_region" {
  description = "AWS region"
  value       = var.region
}