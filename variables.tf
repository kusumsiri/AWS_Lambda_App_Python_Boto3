variable "table_name" {
  description = "The name for table"
  default = "customers"
}

variable "lambda_runtime_version" {
  description = "Function runtime version"
  default = "python3.10"
}