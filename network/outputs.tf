output "bastion_ssh_sg_id" {
  value = aws_security_group.bastion_ssh_sg.id
}
output "bf_ssh_sg_id" {
  value = aws_security_group.bf_ssh_sg.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet.*.id
}
output "private_subnets_id" {
  value = aws_subnet.private_subnets.*.id
}
output "nat_sec_group_id" {
  value = aws_security_group.nat_sec_group.id
}
output "web_sec_group_id" {
  value = aws_security_group.web_sec_group.id
}
output "alb_arn_suffix" {
  value = aws_lb.tasks_alb.arn_suffix
}
output "tg_arn_suffix" {
  value = aws_lb_target_group.tasks_tg.arn_suffix
}