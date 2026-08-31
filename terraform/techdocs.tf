# ---------------------------------------------------------------------------
# TechDocs — S3 bucket for pre-built documentation (external builder pattern)
# CI builds docs with techdocs-cli and publishes here; Backstage reads only.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "techdocs" {
  bucket        = "onyiglobal-techdocs-bucket"
  force_destroy = true

  tags = {
    Name    = "taskflow-techdocs"
    Project = "taskflow-backstage"
  }
}

resource "aws_s3_bucket_public_access_block" "techdocs" {
  bucket                  = aws_s3_bucket.techdocs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------------------------
# IRSA role for the Backstage pod — read-only access to the docs bucket
# Namespace and service account are fixed by the Helm install in Step 2.
# ---------------------------------------------------------------------------

resource "aws_iam_role" "backstage" {
  name = "taskflow-backstage-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:backstage:backstage"
          }
        }
      }
    ]
  })

  tags = {
    Name = "taskflow-backstage-role"
  }
}

resource "aws_iam_policy" "backstage_techdocs_read" {
  name        = "taskflow-backstage-techdocs-read"
  description = "Allows Backstage to read pre-built TechDocs from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.techdocs.arn,
          "${aws_s3_bucket.techdocs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backstage_techdocs_read" {
  role       = aws_iam_role.backstage.name
  policy_arn = aws_iam_policy.backstage_techdocs_read.arn
}

# ---------------------------------------------------------------------------
# Write access for the existing GitHub Actions OIDC role — publishes docs
# ---------------------------------------------------------------------------

resource "aws_iam_policy" "github_actions_techdocs_write" {
  name        = "taskflow-github-actions-techdocs-write"
  description = "Allows CI to publish built TechDocs to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.techdocs.arn,
          "${aws_s3_bucket.techdocs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_techdocs_write" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_techdocs_write.arn
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "techdocs_bucket_name" {
  description = "S3 bucket holding pre-built TechDocs"
  value       = aws_s3_bucket.techdocs.id
}

output "backstage_role_arn" {
  description = "IRSA role ARN to annotate the Backstage service account with"
  value       = aws_iam_role.backstage.arn
}