terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19"
    }
  }
}

provider "aws" {
  region = "eu-south-1"
}

locals {
  common_tags = {
    project       = "required DO NOT DELETE"
    resourceowner = "Francesco.Riosa@kyndryl.com"
    customer      = "any"
  }
}

resource "aws_s3_bucket" "backend_s3_bucket" {
  bucket = "tfstates-n34bc4bjy6vw9gw4"
  tags = merge( local.common_tags, { Name = "tfstates-n34bc4bjy6vw9gw4" } )
}

# resource "aws_s3_bucket_acl" "backend_s3_bucket" {
#   bucket = aws_s3_bucket.backend_s3_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "backend_s3_bucket" {
  bucket = aws_s3_bucket.backend_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
