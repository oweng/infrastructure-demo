#!/bin/bash

check_exit_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

 #Create S3 Bucket
export AWSACCOUNT=`aws sts get-caller-identity --query Account --output text` 
S3_BUCKET_NAME="demo-terraform-backend-${AWSACCOUNT}"
aws s3 mb "s3://$S3_BUCKET_NAME" --region "us-east-1"

# Enable Versioning for S3 Bucket
aws s3api put-bucket-versioning --bucket "$S3_BUCKET_NAME" --versioning-configuration Status=Enabled

check_exit_status "Failed to add bucket versioning"

# Creating DynamoDB Table
aws dynamodb create-table \
  --table-name "tf-lock-table" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region "us-east-1"

check_exit_status "Failed to create dynamodb table"

