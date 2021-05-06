terraform{
  backend "s3" {
    bucket = "my-aws-cicd2021"
    encrypt = true
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}