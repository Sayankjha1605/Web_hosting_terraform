terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# create an s3 bucket

terraform {
  backend "s3" {
    bucket = "sayankbucket"
    key = "sayankkibucket/terraform.tfstate"
    region = var.region
    access_key = var.access_key
   secret_key = var.secret_key

  }
  
}

