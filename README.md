# AWS Lambda Application with Python & Boto3
The boto3 SDK can be used to integrate the Python language with AWS services. Here when a json file is uploaded to the S3 bucket, a Lambda function is triggered to read it and store the data in a DynamoDB table. Terraform is used to create the S3 bucket, DynamoDB table and S3 trigger.
The [sample.json](sample.json) file can be used to test the application. If the format of the json file is incorrect, the error will be logged as an Amazon CloudWatch entry.
