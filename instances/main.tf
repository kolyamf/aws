# nat instance #
resource "aws_network_interface" "nat" {
  subnet_id   = element(var.public_subnet_id, 0)
  private_ips = ["172.30.5.158"]
  source_dest_check           = false
  security_groups             = [
  var.nat_sec_group_id,
  var.bastion_ssh_sg_id,
  var.web_sec_group_id
  ]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_eip" "public_ip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.nat.id
  associate_with_private_ip = "172.30.5.158"
}

resource "aws_instance" "nat" {
  ami                         = var.nat_ami
  instance_type               = var.nat_instance_type
  network_interface {
    network_interface_id = aws_network_interface.nat.id
    device_index         = 0
  }
  key_name                    = var.key_name
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