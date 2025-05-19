package main

deny[msg] if {
  input.resource.type == "aws_s3_bucket"
  input.resource.name == "public-bucket"
  msg := "Public S3 buckets are not allowed"
}