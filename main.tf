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