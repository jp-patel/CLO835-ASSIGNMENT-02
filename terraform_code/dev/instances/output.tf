# Add output variables
output "eip" {
  value = aws_eip.CLO835_Week_09_Assignment_02_static_eip.public_ip
}