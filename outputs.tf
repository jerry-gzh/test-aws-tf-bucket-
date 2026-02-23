output "bucket_name" {
  description = "Name of the S3 bucket created for the current environment"
  value       = module.s3_bucket_example.bucket_name
}
