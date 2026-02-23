bucket         = "jerry-infra-tfstates-dev"
key            = "test-aws-tf-bucket/prd/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
