# 1. Deploy Central Transit Gateway & RAM Share
module "tgw_hub" {
  source               = "../../modules/tgw-hub"
  amazon_side_asn      = var.amazon_side_asn
  aws_organization_arn = var.aws_organization_arn
}

# 2. Deploy Hub Inspection VPC (Public, Transit, and Management Subnets)
module "inspection_vpc" {
  source = "../../modules/inspection-vpc"

  environment               = local.environment
  vpc_cidr                  = var.hub_vpc_cidr
  transit_gateway_id        = module.tgw_hub.transit_gateway_id
  inspection_route_table_id = module.tgw_hub.inspection_route_table_id
}

# 3. Deploy Multi-ENI pfSense Firewalls in the Hub
module "inspection_firewall" {
  source                = "../../modules/inspection-firewall"
  environment           = local.environment
  vpc_id                = module.inspection_vpc.vpc_id
  public_subnet_ids     = module.inspection_vpc.public_subnet_ids
  transit_subnet_ids    = module.inspection_vpc.transit_subnet_ids
  management_subnet_ids = module.inspection_vpc.management_subnet_ids
  pfsense_ami_id        = var.pfsense_ami_id
  instance_type         = "t3.medium"
  key_name              = aws_key_pair.pfsense_deploy.key_name
}

# 4. Explicit Independent Route binding TGW/Transit traffic to the firewall's static ENI
resource "aws_route" "inspection_transit_to_pfsense" {
  route_table_id         = module.inspection_vpc.transit_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.inspection_firewall.transit_eni_id
}

resource "aws_key_pair" "pfsense_deploy" {
  key_name   = "pfsense-hub-deploy-key"
  public_key = file("~/.ssh/pfsense_hub_key.pub")
}