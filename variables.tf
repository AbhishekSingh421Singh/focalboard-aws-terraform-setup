variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ports" {
  type    = list(number)
  default = [22, 80, 8000]
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "tags" {
  type    = map(string)
  default = {
    Name        = "focalboard-UC10"
    Environment = "Dev"
  }
}