output "transit_gateway_id" {
  description = "The ID of the central Transit Gateway"
  value       = aws_ec2_transit_gateway.hub.id
}

output "inspection_route_table_id" {
  description = "TGW Route Table ID assigned to the Hub Firewall VPC attachment"
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}

output "spokes_route_table_id" {
  description = "TGW Route Table ID assigned to workload spoke VPC attachments"
  value       = aws_ec2_transit_gateway_route_table.spokes.id
}