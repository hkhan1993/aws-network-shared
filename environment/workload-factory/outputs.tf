output "core_app_1_vpc_id" {
  description = "VPC ID for Core App 1"
  value       = module.workload_app_1_tier.vpc_id
}

output "core_app_2_vpc_id" {
  description = "VPC ID for Core App 2"
  value       = module.workload_app_2_tier.vpc_id
}

output "core_app_1_tgw_attachment_id" {
  description = "Transit Gateway attachment ID for Core App 1"
  value       = module.workload_app_1_tier.transit_gateway_attachment_id
}

output "core_app_2_tgw_attachment_id" {
  description = "Transit Gateway attachment ID for Core App 2"
  value       = module.workload_app_2_tier.transit_gateway_attachment_id
}