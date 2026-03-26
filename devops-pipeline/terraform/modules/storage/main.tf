resource "aws_s3_bucket" "appBucket" {
  bucket = "${var.project_name}-${var.environment}-${random_id.suffix.hex}"

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "appBucket" {
  bucket = aws_s3_bucket.appBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "appBucket" {
  bucket = aws_s3_bucket.appBucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "appBucket" {
  bucket                  = aws_s3_bucket.appBucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
