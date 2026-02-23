variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project identifier used in resource names"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used in unique resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, qas, prd)"
  type        = string
}
