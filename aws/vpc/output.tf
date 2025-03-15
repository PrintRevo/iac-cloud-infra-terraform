output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "aws_security_group_public_access_id" {
  value = aws_security_group.public_access.id
}