variable "aws_region" {
  default     = "ap-south-1"
  description = "AWS Region"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "ubuntu"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ALB and EC2"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for ALB and EC2"
}

variable "environment" {
  default     = "blue"
  description = "Environment name: blue or green"
}