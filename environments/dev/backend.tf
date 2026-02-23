terraform {
  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "jerry-infra-tfstates-dev"
    key            = "test-aws-tf-bucket/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
