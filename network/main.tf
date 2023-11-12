# internet gateway #
resource "aws_internet_gateway" "tasks_igw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "${var.vpc_name}-igw"
  }
}
# public subnet section #
resource "aws_subnet" "public_subnet" {
  count             = length(var.subnets_az)
  vpc_id            = var.vpc_id
  availability_zone = element(var.subnets_az, count.index)
  cidr_block        = cidrsubnet(aws_vpc.tasks_vpc.cidr_block, 8, count.index+5)
  tags = {
    Name = "${var.vpc_name}-public-${count.index+1}"
  }
}
resource "aws_route_table" "tasks_pub_route" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tasks_igw.id
    }
    tags = {
        Name = "${var.vpc_name}-public-route"
    }
}
resource "aws_route_table_association" "tasks_pub_association" {
    count          = length(var.subnets_az)
    subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_route_table.tasks_pub_route.id
}

# private subnets section #
resource "aws_subnet" "private_subnets" {
  count             = length(var.subnets_az)
  vpc_id            = var.vpc_id
  availability_zone = element(var.subnets_az, count.index)
  cidr_block        = cidrsubnet(aws_vpc.tasks_vpc.cidr_block, 8, count.index+10)
  tags = {
    Name = "${var.vpc_name}-private-${count.index+1}"
  }
}
resource "aws_route_table" "tasks_priv_route" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        network_interface_id = var.nat_id
    }
    tags = {
    Name = "${var.vpc_name}-private-route"
  }
}
resource "aws_route_table_association" "tasks_priv_association" {
    route_table_id = aws_route_table.tasks_priv_route.id
    count          = length(var.subnets_az)
    subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}
# Security groups section #
resource "aws_security_group" "nat_sec_group" {
    name = "${var.vpc_name}-nat-sg"
    description = "NAT security group"
    vpc_id = var.vpc_id
    # Allow HTTP, HTTPS, SSH #
    dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = aws_subnet.private_subnets.*.cidr_block
    }
  }
    # Allow all to out #
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-nat-security-group"
  }
}
resource "aws_security_group" "web_sec_group" {
    name = "${var.vpc_name}-web-sg"
    description = "WEB security group"
    vpc_id = var.vpc_id
    # Allow HTTP #
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-web-security-group"
  }
}
resource "aws_security_group" "bastion_ssh_sg" {
    name = "${var.vpc_name}-bastion-sg"
    description = "bastion security group"
    vpc_id = var.vpc_id
    # Allow SSH #
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
    # Allow all to out #
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-bastion-security-group"
  }
}
resource "aws_security_group" "bf_ssh_sg" {
    name = "${var.vpc_name}-bastion-fsg"
    description = "ssh-from bastion"
    vpc_id = var.vpc_id
    # Allow connect from bastion via SSH # 
    ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      aws_security_group.bastion_ssh_sg.id,
      aws_security_group.nat_sec_group.id
    ]
  }
    # Allow all to out #
    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-from-ssh-bastion-security-group"
  }
}
resource "aws_security_group" "alb_sg" {
  name        = "${var.vpc_name}-ALB-SG"
  description = "ALB SG"
  vpc_id = var.vpc_id
   tags = {
    Name = "${var.vpc_name}-ALB-SG"
  }
  # Allow requets from intranet servers #
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access #
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ACL section #
resource "aws_network_acl" "public" {
  count = length(var.subnets_az) > 0 ? 1 : 0
  vpc_id = var.vpc_id
  subnet_ids = aws_subnet.public_subnet.*.id
  tags = {
    Name = "${var.vpc_name}-public-acl"
  }
}
resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.subnets_az) > 0 ? length(var.public_inbound_acl_rules) : 0
  network_acl_id = aws_network_acl.public[0].id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = var.public_inbound_acl_rules[count.index]["from_port"]
  to_port     = var.public_inbound_acl_rules[count.index]["to_port"]
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = var.public_inbound_acl_rules[count.index]["cidr_block"]
}
resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.subnets_az) > 0 ? length(var.public_outbound_acl_rules) : 0
  network_acl_id = aws_network_acl.public[0].id
  egress         = true
  rule_number    = var.public_outbound_acl_rules[count.index]["rule_number"] 
  protocol       = var.public_outbound_acl_rules[count.index]["protocol"]
  rule_action    = var.public_outbound_acl_rules[count.index]["rule_action"]
  cidr_block     = var.public_outbound_acl_rules[count.index]["cidr_block"]
  from_port      = var.public_outbound_acl_rules[count.index]["from_port"]
  to_port        = var.public_outbound_acl_rules[count.index]["to_port"]
}
resource "aws_network_acl" "private" {
  count = length(var.subnets_az) > 0 ? 1 : 0
  vpc_id = var.vpc_id
  subnet_ids = aws_subnet.private_subnets.*.id
  tags = {
    Name = "${var.vpc_name}-private-acl"
  }
}
resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.subnets_az) > 0 ? length(var.private_outbound_acl_rules) : 0
  network_acl_id = aws_network_acl.private[0].id
  egress         = false
  rule_number    = var.private_outbound_acl_rules[count.index]["rule_number"] 
  protocol       = var.private_outbound_acl_rules[count.index]["protocol"]
  rule_action    = var.private_outbound_acl_rules[count.index]["rule_action"]
  cidr_block     = var.private_outbound_acl_rules[count.index]["cidr_block"]
  from_port      = var.private_outbound_acl_rules[count.index]["from_port"]
  to_port        = var.private_outbound_acl_rules[count.index]["to_port"]
}
resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.subnets_az) > 0 ? length(var.private_outbound_acl_rules) : 0
  network_acl_id = aws_network_acl.private[0].id
  egress         = true
  rule_number    = var.private_outbound_acl_rules[count.index]["rule_number"] 
  protocol       = var.private_outbound_acl_rules[count.index]["protocol"]
  rule_action    = var.private_outbound_acl_rules[count.index]["rule_action"]
  cidr_block     = var.private_outbound_acl_rules[count.index]["cidr_block"]
  from_port      = var.private_outbound_acl_rules[count.index]["from_port"]
  to_port        = var.private_outbound_acl_rules[count.index]["to_port"]
}
# Application Load Balancer #
resource "aws_lb" "tasks_alb" {
  name = "${var.vpc_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet.*.id
  enable_cross_zone_load_balancing = false
  tags = {
    Name = "${var.vpc_name}-ALB"
  }
}
resource "aws_lb_target_group" "tasks_tg" {
  name               = "${var.vpc_name}-tg"
  port               = 80
  protocol           = "HTTP"
  vpc_id             = var.vpc_id
  tags = {
    Name = "${var.vpc_name}-TG"
  }
}
resource "aws_lb_target_group_attachment" "tasks_tg_attach" {
  target_group_arn = aws_lb_target_group.tasks_tg.arn
  count            = length(var.private_subnet_instances)
  target_id        = element(var.private_subnet_instances, count.index)
  port             = 80
}
resource "aws_lb_listener" "tasks_listener" {
  load_balancer_arn = aws_lb.tasks_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tasks_tg.arn
  }
}