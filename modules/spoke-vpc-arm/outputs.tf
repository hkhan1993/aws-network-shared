output "vpc_id" {
  description = "The ID of the spoke VPC"
  value       = aws_vpc.spoke.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs of the private application subnets (TGW attached)"
  value       = aws_subnet.private_app[*].id
}

output "database_subnet_ids" {
  description = "IDs of the isolated database subnets"
  value       = aws_subnet.database[*].id
}

output "transit_gateway_attachment_id" {
  description = "The ID of the TGW attachment linking this spoke"
  value       = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}