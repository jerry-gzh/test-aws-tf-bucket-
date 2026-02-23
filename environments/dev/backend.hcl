bucket         = "jerry-infra-tfstates-dev"
key            = "test-aws-tf-bucket/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
