variable "amazon_side_asn" {
  type        = number
  description = "Autonomous System Number for the TGW. Required by AWS even for static setups."
  default     = 64512
}

variable "aws_organization_arn" {
  type        = string
  description = "The ARN of your AWS Organization to permit cross-account RAM sharing."
}