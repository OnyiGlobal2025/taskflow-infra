# GitHub Actions OIDC provider already exists — import the existing one
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# IAM role that GitHub Actions pipeline assumes
resource "aws_iam_role" "github_actions" {
  name = "taskflow-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:OnyiGlobal2025/taskflow-app:*",
              # ── CROSSPLANE (Project 6, Phase 0): START ──
              # Removed: "repo:OnyiGlobal2025/taskflow-backstage:*"
              # Reason: taskflow-backstage was created after 2026-07-15, so its subject
              # uses the numeric format and is covered by the org wildcard below.
              # old: "repo:OnyiGlobal2025/taskflow-backstage:*",
              # ── CROSSPLANE (Project 6, Phase 0): END ──
              "repo:OnyiGlobal2025/taskflow-infra:*",
              "repo:OnyiGlobal2025/taskflow-gitops:*",
              # ── CROSSPLANE (Project 6, Phase 0): START ──
              # Introduced: org-scoped wildcard for immutable subject claims. Repos created
              # after 2026-07-15 embed numeric org/repo IDs, which the legacy patterns above
              # cannot match. Covers taskflow-backstage, taskflow-crossplane, and scaffolded
              # services whose repo IDs are unknown at apply time. Org ID stays pinned.
              "repo:OnyiGlobal2025@232406732/*:*",
              # ── CROSSPLANE (Project 6, Phase 0): END ──
            ]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "taskflow-github-actions-role"
  }
}

# Policy giving the pipeline what it needs
resource "aws_iam_policy" "github_actions" {
  name = "taskflow-github-actions-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        # ── CROSSPLANE (Project 6, Phase 0): START ──
        # Introduced: wildcard ECR resource. Scaffolded services get their own ECR
        # repos, which are unknown at apply time, so one named repo cannot cover them.
        # Replaced: Resource = aws_ecr_repository.taskflow.arn
        # old: Resource = aws_ecr_repository.taskflow.arn
        Resource = "arn:aws:ecr:us-east-1:713923090919:repository/*"
        # ── CROSSPLANE (Project 6, Phase 0): END ──
      },
      # ── CROSSPLANE (Project 6, Phase 0): START ──
      # Commented out: ECRCreateForScaffoldedServices lets CI create any ECR repo
      # with Resource = "*". That is the Issue 30 workaround this project replaces.
      # Crossplane should create repos instead. Restore only if there is a reason.
      # {
      #   Sid    = "ECRCreateForScaffoldedServices"
      #   Effect = "Allow"
      #   Action = [
      #     "ecr:CreateRepository",
      #     "ecr:DescribeRepositories",
      #     "ecr:PutImageScanningConfiguration"
      #   ]
      #   Resource = "*"
      # },
      # ── CROSSPLANE (Project 6, Phase 0): END ──
      {
        Sid      = "EKSDescribeForKubeconfig"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = aws_eks_cluster.taskflow_eks_cluster.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}