# 1. The Central Transit Gateway
resource "aws_ec2_transit_gateway" "hub" {
  description                     = "Landing Zone Hub Transit Gateway"
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "lz-core-tgw"
  }
}

# 2. AWS RAM (Resource Access Manager) - Shares TGW with your AWS Org
resource "aws_ram_resource_share" "tgw" {
  name                      = "lz-transit-gateway-share"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.hub.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "org" {
  resource_share_arn = aws_ram_resource_share.tgw.arn
  principal          = var.aws_organization_arn
}

# 3. Custom TGW Route Tables for Traffic Segmentation
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  tags = { Name = "tgw-rt-inspection" }
}

resource "aws_ec2_transit_gateway_route_table" "spokes" {
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  tags = { Name = "tgw-rt-spokes" }
}