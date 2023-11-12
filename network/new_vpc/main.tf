# vpc section #
resource "aws_vpc" "tasks_vpc" {
    count = var.create_new_vpc ? 1:0
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.vpc_name}"
  }
}