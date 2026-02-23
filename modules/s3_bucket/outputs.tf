output "bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}
