terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "hkhan1993-tfstate-us-east-1"
    key     = "network-connectivity/workload-factory/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "terraform_user"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "terraform_user"
  assume_role {
    role_arn     = "arn:aws:iam::495791792122:role/OrganizationAccountAccessRole"
    session_name = "TerraformWorkloadFactorySession"
  }
}