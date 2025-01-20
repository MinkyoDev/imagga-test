# GitHub OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub의 공개 인증서 지문
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# GitHub Actions를 위한 IAM Role
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  # GitHub Actions가 이 Role을 사용할 수 있도록 신뢰 정책 설정
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_repository}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# S3 및 CloudFront 권한 정책
resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:UpdateFunction",
          "cloudfront:DescribeFunction",
          "cloudfront:PublishFunction"
        ]
        Resource = [
          "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:function/url_rewrite"
        ]
      }
    ]
  })
}

# 현재 AWS 계정 ID 가져오기
data "aws_caller_identity" "current" {}

# 변수 정의
variable "github_repository" {
  type        = string
  description = "GitHub repository identifier (e.g., 'organization/repository')"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
  default     = "imagga-kr-2025"
}

# 출력 설정
output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
  description = "ARN of the GitHub Actions IAM role"
}