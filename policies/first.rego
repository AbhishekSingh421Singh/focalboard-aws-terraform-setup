package main

deny[msg] {
  r := input.resource_changes[_]
  r.type == "aws_s3_bucket"
  r.change.after.acl == "public-read"
  msg := "S3 bucket is public!"
}