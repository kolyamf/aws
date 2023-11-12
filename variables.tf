variable "region" { default = "us-east-1" }

# vpc variables #
variable "create_new_vpc" {
  type = bool
}

variable "vpc_name" {
  description = "name of the VPC"
  default     = "newcomer-tasks"
}
variable "vpc_cidr" {
  description = "cidr of all VPC"
  default     = "172.30.0.0/16"
}
# subnets variables #
variable "subnets_az" {
  description = "priv_count"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
variable "key_name" { default = "ec2" }
variable "nat_instance_type" {
  default = "t2.micro"
}
variable "web_instance_type" {
  default = "t2.micro"
}