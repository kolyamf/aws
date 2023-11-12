terraform {
  required_version = "1.6.3"
}
provider "aws" {
  profile = "terraform_user"
  region  = var.region

}

locals {
  nat_ami = data.aws_ami.ubuntu.id
  web_ami = data.aws_ami.ubuntu.id
  vpc_id = var.create_new_vpc ? module.new_vpc.vpc_id : data.aws_vpc.default.id
}

output "vpc_name" {
  value = local.vpc_id
}

module "new_vpc" {
  source         = "./network/new_vpc"
  vpc_name       = var.vpc_name
  vpc_cidr       = var.vpc_cidr
  create_new_vpc = var.create_new_vpc
}

module "network" {
  source                   = "./network"
  vpc_id                   = local.vpc_id
  vpc_name                 = var.vpc_name
  vpc_cidr                 = var.vpc_cidr
  nat_id                   = module.instances.nat_id
  private_subnet_instances = module.instances.private_subnet_instances
  subnets_az               = var.subnets_az
}
module "instances" {
  source             = "./instances"
  bastion_ssh_sg_id  = module.network.bastion_ssh_sg_id
  public_subnet_id   = module.network.public_subnet_id
  web_sec_group_id   = module.network.web_sec_group_id
  nat_sec_group_id   = module.network.nat_sec_group_id
  region             = var.region
  nat_instance_type  = var.nat_instance_type
  key_name           = var.key_name
  vpc_name           = var.vpc_name
  web_instance_type  = var.web_instance_type
  subnets_az         = var.subnets_az
  private_subnets_id = module.network.private_subnets_id
  bf_ssh_sg_id       = module.network.bf_ssh_sg_id
  nat_ami            = local.nat_ami
  web_ami            = local.web_ami
}