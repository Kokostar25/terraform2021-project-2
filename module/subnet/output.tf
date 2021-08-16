
output "private_subnet_id" {
    value = aws_subnet.koko-pri.*.id
}

output "public_subnet_id" {
    value = aws_subnet.koko-pub.*.id
     
}


