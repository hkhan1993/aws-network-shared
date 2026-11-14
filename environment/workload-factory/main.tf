# ==========================================
# DEFAULT ROUTE ON EXISTING SPOKE TGW RT
# ==========================================
# Points all outbound traffic from the existing spoke TGW route table to the inspection hub attachment
resource "aws_ec2_transit_gateway_route" "spoke_default_to_inspection" {
  transit_gateway_route_table_id = var.transit_gateway_spoke_route_table_id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.inspection_tgw_attachment_id
}


# --- Workload Tier 1 (Core App 1) ---
module "workload_app_1_tier" {
  source = "../../modules/workload-factory"

  environment                          = var.environment
  workload_name                        = "core-app-1"
  vpc_cidr                             = "10.201.0.0/20"
  subnet_cidrs                         = ["10.201.0.0/22", "10.201.4.0/22"]
  availability_zones                   = ["us-east-1a", "us-east-1b"]
  transit_gateway_id                   = var.transit_gateway_id
  transit_gateway_spoke_route_table_id = var.transit_gateway_spoke_route_table_id

  subnet_sharing_map = {
    "0" = "786589010147"
    "1" = "786589010147"
  }
}

# --- Workload Tier 2 (Core App 2) ---
module "workload_app_2_tier" {
  source = "../../modules/workload-factory"

  environment                          = var.environment
  workload_name                        = "core-app-2"
  vpc_cidr                             = "10.202.0.0/20"
  subnet_cidrs                         = ["10.202.0.0/22", "10.202.4.0/22"]
  availability_zones                   = ["us-east-1a", "us-east-1b"]
  transit_gateway_id                   = var.transit_gateway_id
  transit_gateway_spoke_route_table_id = var.transit_gateway_spoke_route_table_id

  subnet_sharing_map = {
    "0" = "239711842146"
    "1" = "239711842146"
  }
}


# ==========================================
# CORE APP 1: VPC ENDPOINT CONFIGURATION
# ==========================================

resource "aws_security_group" "vpc_endpoints_app1" {
  name        = "core-app-1-vpc-endpoints-sg"
  description = "Allow TLS inbound for SSM interface endpoints in core-app-1 VPC"
  vpc_id      = module.workload_app_1_tier.vpc_id

  ingress {
    description = "Allow HTTPS from Core App 1 VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.workload_app_1_tier.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc_endpoints_app1" {
  source             = "../../modules/vpc_endpoints"
  vpc_id             = module.workload_app_1_tier.vpc_id
  subnet_ids         = module.workload_app_1_tier.subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_app1.id]
  aws_region         = "us-east-1"
}


# ==========================================
# CORE APP 2: VPC ENDPOINT CONFIGURATION
# ==========================================

resource "aws_security_group" "vpc_endpoints_app2" {
  name        = "core-app-2-vpc-endpoints-sg"
  description = "Allow TLS inbound for SSM interface endpoints in core-app-2 VPC"
  vpc_id      = module.workload_app_2_tier.vpc_id

  ingress {
    description = "Allow HTTPS from Core App 2 VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.workload_app_2_tier.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc_endpoints_app2" {
  source             = "../../modules/vpc_endpoints"
  vpc_id             = module.workload_app_2_tier.vpc_id
  subnet_ids         = module.workload_app_2_tier.subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints_app2.id]
  aws_region         = "us-east-1"
}


# ==========================================
# TGW HUB ROUTE TABLE ENTRIES FOR SPOKES
# ==========================================

resource "aws_ec2_transit_gateway_route" "hub_to_core_app_1" {
  transit_gateway_route_table_id = var.inspection_tgw_route_table_id
  destination_cidr_block         = module.workload_app_1_tier.vpc_cidr
  transit_gateway_attachment_id  = module.workload_app_1_tier.transit_gateway_attachment_id
}

resource "aws_ec2_transit_gateway_route" "hub_to_core_app_2" {
  transit_gateway_route_table_id = var.inspection_tgw_route_table_id
  destination_cidr_block         = module.workload_app_2_tier.vpc_cidr
  transit_gateway_attachment_id  = module.workload_app_2_tier.transit_gateway_attachment_id
}