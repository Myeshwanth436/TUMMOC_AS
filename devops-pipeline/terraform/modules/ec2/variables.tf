variable "project_name"      { type = string }
variable "environment"       { type = string }
variable "vpc_id"            { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "key_name"          { type = string }
variable "instance_type"     { type = string; default = "t3.micro" }
variable "ami_id"            { type = string }
variable "s3_bucket_name"    { type = string }
