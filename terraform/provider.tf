# use terraform cloud
terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "geisslersolutions"

    workspaces {
      name = "aws-learning-env"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}