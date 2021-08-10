output "pub_subnet_id" {
    value = aws_subnet.koko-pub.*.id
     
}

output "pri_subnet_id" {
    value = aws_subnet.koko-pri.*.id
}

