# Add output variables
output "eip" {
  value = aws_eip.CLO835_week_09_Assignment_02_static_eip.public_ip
}