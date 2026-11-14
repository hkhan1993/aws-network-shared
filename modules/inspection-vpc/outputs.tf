output "vpc_id" { value = aws_vpc.hub.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "transit_subnet_ids" { value = aws_subnet.transit[*].id }
output "management_subnet_ids" { value = aws_subnet.management[*].id }
output "transit_route_table_id" { value = aws_route_table.transit.id }