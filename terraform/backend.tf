terraform {
  backend "s3" {
    bucket         = "onyiglobal-terraform-state-bucket" # Replace with your S3 bucket name
    key            = "taskflow-infra/terraform.tfstate"  # Path to store the state file in the bucket
    region         = "us-east-1"                         # The region of your S3 bucket
    encrypt        = true                                # Enable encryption for security
    dynamodb_table = "terraform-lock-table"              # The DynamoDB table for state locking
  }
}