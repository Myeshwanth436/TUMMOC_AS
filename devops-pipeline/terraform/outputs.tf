output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "app_url" {
  description = "Application URL"
  value       = "http://${module.ec2.public_ip}:8080"
}

output "s3_bucket_name" {
  description = "S3 bucket for app artifacts"
  value       = module.storage.bucket_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}
