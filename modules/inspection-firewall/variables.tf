variable "environment" {
  type        = string
  default     = "hub-inspection"
  description = "Environment name prefix."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the Hub Inspection VPC."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for WAN interfaces."
}

variable "transit_subnet_ids" {
  type        = list(string)
  description = "List of transit subnet IDs for LAN/TGW interfaces."
}

variable "management_subnet_ids" {
  type        = list(string)
  description = "List of management subnet IDs for administrative access."
}

variable "pfsense_ami_id" {
  type        = string
  description = "AWS Marketplace or custom AMI ID for pfSense."
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance size for the firewall."
}

variable "key_name" {
  type        = string
  description = "Name of the AWS EC2 Key Pair for SSH access."
}