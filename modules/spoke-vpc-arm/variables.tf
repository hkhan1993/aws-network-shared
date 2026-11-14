variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the spoke VPC (e.g., 10.100.0.0/16)."
}

variable "environment" {
  type        = string
  description = "Name of the environment or workload account (e.g., dev, prod)."
}

variable "transit_gateway_id" {
  type        = string
  description = "The ID of the central Hub Transit Gateway."
}

variable "tgw_spoke_route_table_id" {
  type        = string
  description = "The TGW route table ID designated for spoke VPC attachments."
}

variable "inspection_route_table_id" {
  type        = string
  description = "The TGW inspection route table ID for reverse routing propagation."
}