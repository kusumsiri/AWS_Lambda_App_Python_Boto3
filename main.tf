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
    Version   = "2012-10-17"
    Statement = [{
      Action  = "sts:AssumeRole"
      Effect  = "Allow"
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
      Effect  = "Allow"
      Action  = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "dynamodb:*"
      ]
      Resource = ["${aws_dynamodb_table.dynamodb_table.arn}"]
    }]
  })
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "customer.py"
  output_path = "customer.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "customer"
  filename         = data.archive_file.zip.output_path
  # source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.iam_role.arn
  handler = "customer.lambda_handler"
  runtime = var.lambda_runtime_version
}