terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    organization = "orion-x"

    workspaces {
      name = "DevilOps-eks"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}


data "aws_vpc" "default" {
  provider = aws
}