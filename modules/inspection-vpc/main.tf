resource "aws_vpc" "hub" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "vpc-${var.environment}" }
}

resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id

  tags = { Name = "igw-${var.environment}" }
}

# 1. Public Subnets (/27 blocks)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-public-${count.index}" }
}

# 2. Transit Subnets (/27 blocks)
resource "aws_subnet" "transit" {
  count             = 2
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-transit-${count.index}" }
}

# 3. Management Subnets (/27 blocks)
resource "aws_subnet" "management" {
  count             = 2
  vpc_id            = aws_vpc.hub.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-management-${count.index}" }
}

# --- Transit Gateway Attachment for the Hub ---
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.hub.id
  subnet_ids         = aws_subnet.transit[*].id
  dns_support        = "enable"

  tags = { Name = "tgw-att-${var.environment}" }
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = var.inspection_route_table_id
}

# --- Route Tables ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.hub.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub.id
  }

  tags = { Name = "rt-${var.environment}-public" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "transit" {
  vpc_id = aws_vpc.hub.id

  tags = { Name = "rt-${var.environment}-inspection-transit" }
}

resource "aws_route_table_association" "transit" {
  count          = length(aws_subnet.transit)
  subnet_id      = aws_subnet.transit[count.index].id
  route_table_id = aws_route_table.transit.id
}

resource "aws_route_table" "management" {
  vpc_id = aws_vpc.hub.id

  tags = { Name = "rt-${var.environment}-management" }
}

resource "aws_route_table_association" "management" {
  count          = 2
  subnet_id      = aws_subnet.management[count.index].id
  route_table_id = aws_route_table.management.id
}