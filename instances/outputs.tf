output "nat_id" {
  value = aws_network_interface.nat.id
}
output "private_subnet_instances" {
  value = aws_instance.webservers.*.id
}