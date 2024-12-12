variable "AWS_ACCESS_KEY_ID" {}

variable "AWS_SECRET_ACCESS_KEY" {}

variable "AWS_REGION" {}

variable "subnets" {
  default = ["subnet-008c0ddc6c819b76b", "subnet-09cc2d78f02409a3a"]
}

variable "vpc_id" {
  default = "vpc-0b5830bd356ede7f1"
  type    = string
}
