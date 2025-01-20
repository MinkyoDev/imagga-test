# CloudFront 배포 설정
resource "aws_cloudfront_distribution" "static_website" {
  enabled = true
  
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = "static_website_origin"  # S3Origin에서 변경
    
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website.id
  }
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static_website_origin"  # S3Origin에서 변경
    
    # URL 변환을 위한 Function 연결
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# CloudFront Function 생성
resource "aws_cloudfront_function" "url_rewrite" {
  name    = "url_rewrite"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("url-router.js")
}