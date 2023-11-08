# nat instance #
resource "aws_instance" "nat" {
  ami                         = var.nat_ami
  instance_type               = var.nat_instance_type
  key_name                    = var.key_name
  security_groups             = [
  var.nat_sec_group_id,
  var.bastion_ssh_sg_id,
  var.web_sec_group_id
  ]
  subnet_id                   = element(var.public_subnet_id, 0)
  associate_public_ip_address = true
  source_dest_check           = false
  tags = {
    Name = "${var.vpc_name}-bastion"
  }
}
data "template_file" "weberver_data"{
  template = "${file("${path.module}/web-data.sh.tpl")}"
}
# Web instances #
resource "aws_instance" "webservers" {
  ami = var.web_ami
  instance_type = var.web_instance_type
  count = length(var.subnets_az)
  subnet_id = element(var.private_subnets_id, count.index+2)
  associate_public_ip_address = false
  user_data = data.template_file.weberver_data.rendered
  vpc_security_group_ids = [
  var.bf_ssh_sg_id,
  var.web_sec_group_id
  ]
  key_name = var.key_name
  tags = {
    Name = "${var.vpc_name}-webserver-${count.index+1}"
  }
}