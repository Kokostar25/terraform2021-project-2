output "public_subnet_id" {
    value = aws_subnet.koko-pub.*.id
     
}

output "private_subnet_id" {
    value = aws_subnet.koko-pri.*.id
}

