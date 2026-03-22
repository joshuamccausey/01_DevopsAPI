terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
  # Create state storage buck
  backend "s3" {
    bucket = "01-devopsapi-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }

  required_version = ">= 1.2"
}
