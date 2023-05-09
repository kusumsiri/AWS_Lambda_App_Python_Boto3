variable "table_name" {
  description = "The name for table"
  default = "customers"
}

variable "lambda_runtime_version" {
  description = "Python runtime version"
  default = "python3.10"
}
