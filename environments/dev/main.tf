variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "example" {
  bucket = "jerry-gzh-repo-a-dev-example-839406385516"
}
