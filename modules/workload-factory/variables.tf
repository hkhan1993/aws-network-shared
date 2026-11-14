variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "workload_name" {
  type        = string
  description = "Name of the workload"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the workload VPC"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones"
}

variable "transit_gateway_id" {
  type        = string
  description = "Central Transit Gateway ID"
}

variable "transit_gateway_spoke_route_table_id" {
  type        = string
  description = "The single shared TGW route table ID for all spokes"
}

variable "subnet_sharing_map" {
  type        = map(string)
  description = "Mapping of subnet index to target AWS Account ID for RAM sharing"
  default     = {}
}