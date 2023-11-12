variable "vpc_name" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "nat_id" {}
variable "private_subnet_instances" {}
variable "subnets_az" {}
variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))

  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [80, 443, 22]
}
locals {
  subnets_count = "${length(data.aws_availability_zones.az.names)}"
}