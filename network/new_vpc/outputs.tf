output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_new_vpc ? aws_vpc.tasks_vpc[0].id : null
}