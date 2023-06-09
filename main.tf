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
  bucket = "lambda-python-app-bucket-kusumsiri"
  force_destroy = true
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
        "logs:*",
        "lambda:InvokeFunction",
        "cloudwatch:*",
        "dynamodb:*",
        "s3:*",
        "s3:GetObject",
        "s3-object-lambda:*",
        "s3-object-lambda:GetObject",
      ]
      Resource = ["*"]
    },{
      Effect = "Allow",
      Action  = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      Resource = "*"
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_ploicy.arn
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "add_customer.py"
  output_path = "add_customer.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "add_customer"
  filename         = data.archive_file.zip.output_path
  # source_code_hash = data.archive_file.zip.output_base64sha256
  role    = aws_iam_role.iam_role.arn
  handler = "add_customer.lambda_handler"
  runtime = var.lambda_runtime_version
  environment {
    variables = {
      TABLE_NAME            = var.table_name
    }
  }
}

# S3 as trigger to lambda
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}


