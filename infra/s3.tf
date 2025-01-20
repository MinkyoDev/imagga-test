# S3 버킷
resource "aws_s3_bucket" "static_website" {
  bucket = "imagga-kr-2025"

  force_destroy = true
  
  tags = {
    Name        = "Static Website"
    Environment = "Production"
  }
}

# 버킷 퍼블릭 액세스 설정
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront OAC 생성
resource "aws_cloudfront_origin_access_control" "static_website" {
  name                              = "static_website_oac"
  description                       = "Static Website OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 버킷 정책 - CloudFront OAC만 접근 허용
resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_website.arn
          }
        }
      }
    ]
  })
}

# 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  versioning_configuration {
    status = "Disabled"
  }
}