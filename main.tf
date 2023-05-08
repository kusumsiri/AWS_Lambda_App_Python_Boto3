terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "dynamodb_table" {
    name        = var.table_name
    hash_key    = "ID"
    billing_mode= "PAY_PER_REQUEST"
    stream_enabled   = false

    attribute {
      name = "ID"
      type = "S"
    }

}

resource "aws_s3_bucket" "bucket" {
  bucket = "kusumsiri-test-bucket"
}

resource "aws_iam_role" "iam_role" {
  name = "Lambda-python-app-role"
  description = "Lambda python app role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "iam_ploicy" {
  name        = "Lambda-python-app-policy"
  description = "Allow lambda function to write on dynamodb"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:*"
      ]
      Resource = ["${aws_dynamodb_table.dynamodb_table.arn}"]
    }]
  })
}