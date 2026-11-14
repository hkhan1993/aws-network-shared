# 1. Base VPC Provisioning
resource "aws_vpc" "spoke" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.environment}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.spoke.id

  tags = {
    Name = "igw-${var.environment}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# 2. 3-Tier Subnet Slicing (Carving /20 subnets out of a /16 VPC across 2 AZs)
# Public Subnets (Indices 0, 1)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-public-${count.index}" }
}

# Private App Subnets (Indices 2, 3) - TGW Attached here
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-app-${count.index}" }
}

# Isolated Database Subnets (Indices 4, 5) - No external routes
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.spoke.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "subnet-${var.environment}-db-${count.index}" }
}

# 3. Transit Gateway Attachment (Strictly tied to the Private App Tier)
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.spoke.id
  subnet_ids         = aws_subnet.private_app[*].id
  dns_support        = "enable"

  tags = {
    Name = "tgw-att-${var.environment}"
  }
}

# Associate Spoke with the TGW Spoke Route Table
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = var.tgw_spoke_route_table_id
}

# Propagate Spoke routes so the Hub Inspection VPC knows how to return traffic here
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = var.inspection_route_table_id
}

# 4. Route Tables & Associations
# Public Route Table (Points to IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.spoke.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "rt-${var.environment}-public" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Route Table (Forces all outbound traffic 0.0.0.0/0 into the TGW -> Hub Firewall)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.spoke.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.transit_gateway_id
  }

  tags = { Name = "rt-${var.environment}-app" }
}

resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Database Route Table (Isolated - Local routing only, completely blocked from TGW/IGW)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.spoke.id

  tags = { Name = "rt-${var.environment}-db" }
}

resource "aws_route_table_association" "database" {
  count          = 2
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}