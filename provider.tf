provider "aws" {
  region = var.region
  default_tags {
    tags = {
      System    = "batch"
      Terraform = true
    }
  }
}

terraform {
  required_version = "~>1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.29.0"
    }
  }

  backend "s3" {
    bucket  = "batch-infra-terraform-state"
    key     = "batch-infra.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}


