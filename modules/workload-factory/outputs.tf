output "vpc_id" {
  description = "ID of the created workload VPC"
  value       = aws_vpc.spoke.id
}

output "vpc_cidr" {
  description = "CIDR block of the created workload VPC"
  value       = aws_vpc.spoke.cidr_block
}

output "subnet_ids" {
  description = "List of shared subnet IDs created by the workload factory module"
  value       = [for s in aws_subnet.workload : s.id]
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}

output "ram_resource_share_arns" {
  description = "Map of ARNs for the granular per-subnet AWS RAM resource shares"
  value       = { for k, v in aws_ram_resource_share.subnet_share : k => v.arn }
}