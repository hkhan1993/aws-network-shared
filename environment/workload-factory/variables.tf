variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "workload_name" {
  type        = string
  description = "Name of the workload"
  default     = "core-app"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the workload VPC"
  default     = "10.201.0.0/20"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of subnet CIDRs"
  default     = ["10.201.0.0/22", "10.201.4.0/22"]
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "transit_gateway_id" {
  type        = string
  description = "Central Transit Gateway ID from core network"
}

variable "transit_gateway_spoke_route_table_id" {
  type        = string
  description = "ID of the existing shared Spoke TGW Route Table"
}

variable "inspection_tgw_attachment_id" {
  type        = string
  description = "Transit Gateway attachment ID for the Central Hub/Inspection VPC"
}

variable "inspection_tgw_route_table_id" {
  type        = string
  description = "Transit Gateway route table ID for the Central Hub/Inspection VPC"
}

variable "aws_organization_arn" {
  type        = string
  description = "AWS Organization ARN for RAM sharing"
}