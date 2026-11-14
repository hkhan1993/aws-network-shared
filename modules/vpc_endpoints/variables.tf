variable "vpc_id" {
  description = "The ID of the shared VPC in the network account"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the endpoint ENIs will be placed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to the endpoints allowing port 443"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}