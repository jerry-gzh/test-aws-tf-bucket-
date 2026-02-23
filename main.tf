terraform {
  backend "s3" {}
}

locals {
  bucket_name = "${var.project_name}-${var.environment}-example-${var.aws_account_id}"
}

module "s3_bucket_example" {
  source = "./modules/s3_bucket"

  bucket_name = local.bucket_name
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
