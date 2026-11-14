output "pfsense_instance_id" {
  description = "The EC2 Instance ID of the pfSense firewall"
  value       = aws_instance.pfsense.id
}

output "wan_interface_ip" {
  description = "Private IP of the WAN ENI"
  value       = aws_network_interface.wan.private_ip
}

output "transit_interface_ip" {
  description = "Private IP of the Transit ENI (used as next-hop for TGW routes if needed)"
  value       = aws_network_interface.transit.private_ip
}

output "wan_eni_id" {
  description = "WAN network interface ID"
  value       = aws_network_interface.wan.id
}

output "transit_eni_id" {
  description = "Transit network interface ID (used as routing next-hop)"
  value       = aws_network_interface.transit.id
}

output "management_eni_id" {
  description = "Management network interface ID"
  value       = aws_network_interface.management.id
}

output "wan_public_ip" {
  description = "Static Elastic IP assigned to the WAN interface"
  value       = aws_eip.wan.public_ip
}

output "transit_private_ip" {
  description = "Static private IP of the transit interface"
  value       = "10.0.2.50"
}


