variable "aws_region" {
  default     = "ap-south-1"
  description = "AWS Region"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "ami_id" {
  description = "AMI ID for the instance or launch template"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "environment" {
  description = "Environment name: blue or green"
  type        = string
}

variable "asg_min_size" {
  default     = 1
  description = "Minimum size of the ASG"
}

variable "asg_max_size" {
  default     = 2
  description = "Maximum size of the ASG"
}
