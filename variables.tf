variable "table_name" {
  description = "The name for table"
  default = "customers"
}

variable "lambda_runtime_version" {
  description = "Lambda function runtime version"
  default = "python3.10"
}
