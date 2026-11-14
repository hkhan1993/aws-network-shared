# 1. Spoke Workload VPC
resource "aws_vpc" "spoke" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "vpc-${var.environment}-${var.workload_name}" }
}

# 2. Spoke Subnets
resource "aws_subnet" "workload" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = { Name = "subnet-${var.environment}-${var.workload_name}-${count.index}" }
}

# 3. Spoke Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.spoke.id
  subnet_ids         = aws_subnet.workload[*].id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = { Name = "tgw-att-${var.environment}-${var.workload_name}" }
}

# 4. Spoke VPC Route Table (Local Subnet Route Table)
resource "aws_route_table" "spoke" {
  vpc_id = aws_vpc.spoke.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = { Name = "rt-${var.environment}-${var.workload_name}-spoke" }
}

resource "aws_route_table_association" "spoke" {
  count          = length(aws_subnet.workload)
  subnet_id      = aws_subnet.workload[count.index].id
  route_table_id = aws_route_table.spoke.id
}

# ==========================================
# 5. Spoke TGW Route Table Association
# Associates this module's attachment to the single shared Spoke TGW Route Table
# ==========================================
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  transit_gateway_route_table_id = var.transit_gateway_spoke_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}

# 6. Granular Per-Subnet RAM Shares
resource "aws_ram_resource_share" "subnet_share" {
  for_each                  = var.subnet_sharing_map
  name                      = "ram-share-${var.environment}-${var.workload_name}-subnet-${each.key}"
  allow_external_principals = false

  tags = { Name = "ram-share-${var.environment}-${var.workload_name}-subnet-${each.key}" }
}

resource "aws_ram_resource_association" "subnet_assoc" {
  for_each           = var.subnet_sharing_map
  resource_arn       = aws_subnet.workload[each.key].arn
  resource_share_arn = aws_ram_resource_share.subnet_share[each.key].arn
}

resource "aws_ram_principal_association" "principal_assoc" {
  for_each           = var.subnet_sharing_map
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.subnet_share[each.key].arn
}