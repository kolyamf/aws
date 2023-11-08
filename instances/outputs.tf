output "nat_id" {
  value = aws_instance.nat.id
}
output "private_subnet_instances" {
  value = aws_instance.webservers.*.id
}