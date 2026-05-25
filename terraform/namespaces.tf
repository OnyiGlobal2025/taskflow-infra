resource "kubernetes_namespace" "dev" {
  metadata {
    name = "taskflow-dev"
    labels = {
      environment = "dev"
      project     = "taskflow"
      managed-by  = "terraform"
    }
  }

  depends_on = [aws_eks_node_group.taskflow_eks_node_group]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "taskflow-staging"
    labels = {
      environment = "staging"
      project     = "taskflow"
      managed-by  = "terraform"
    }
  }

  depends_on = [aws_eks_node_group.taskflow_eks_node_group]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "taskflow-prod"
    labels = {
      environment = "prod"
      project     = "taskflow"
      managed-by  = "terraform"
    }
  }

  depends_on = [aws_eks_node_group.taskflow_eks_node_group]
}