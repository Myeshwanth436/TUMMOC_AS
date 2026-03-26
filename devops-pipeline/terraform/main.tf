terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — create this S3 bucket + DynamoDB table first
  backend "s3" {
    bucket         = "devops-demo-tfstate"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-demo-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ── Networking module ───
module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  az_count     = 2
}

# ── Storage module ───
module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

# ── Compute module ────────────────────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  key_name          = var.key_name
  instance_type     = var.instance_type
  ami_id            = var.ami_id
  s3_bucket_name    = module.storage.bucket_name
}
