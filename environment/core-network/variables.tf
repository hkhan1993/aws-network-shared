variable "amazon_side_asn" {
  type        = number
  description = "Autonomous System Number for the central TGW."
  default     = 64512
}

variable "aws_organization_arn" {
  type        = string
  description = "The ARN of your AWS Organization to enable TGW RAM sharing for future workload spokes."
}


variable "hub_vpc_cidr" {
  type        = string
  description = "CIDR block for the hub inspection VPC."
  default     = "10.200.0.0/24"
}

variable "pfsense_ami_id" {
  type        = string
  description = "The valid AWS Marketplace or custom AMI ID for pfSense in us-east-1."
}