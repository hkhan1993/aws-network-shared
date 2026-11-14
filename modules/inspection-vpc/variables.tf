variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "inspection_route_table_id" {
  type = string
}

# Add a default so it doesn't break root module calls if omitted
variable "pfsense_transit_eni_id" {
  type    = string
  default = null
}
