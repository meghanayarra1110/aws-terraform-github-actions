output "vpc_id" {
  description = "ID of the Terraform VPC"
  value       = aws_vpc.devops_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.devops_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.devops_server.public_ip
}

output "application_url" {
  description = "URL of the deployed Nginx application"
  value       = "http://${aws_instance.devops_server.public_ip}"
}
