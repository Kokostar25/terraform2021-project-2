// output "public_subnet_id" {
//     value = aws_subnet.koko-pub.*.id
     
// }

// output "private_subnet_id" {
//     value = aws_subnet.koko-pri.*.id
// }

// locals {
//   subnets = {
//     public_1 = aws_subnet.koko-pub_1
//     public_2 = aws_subnet.koko-pub_2
//   }
// }

// locals {
//   subnets = {
//     private_1 = aws_subnet.koko-pri_1
//     private_2 = aws_subnet.koko-pri_2
//   }
// }


// output "private_subnet_id" {
//     value = {for k, v in aws_subnet.koko-pri : k => v.id}
//   }
//   output "public_subnet_id" {
//     value = {for k, v in aws_subnet.koko-pub : k => v.id}
//   }

output "private_subnet_id" {
    value = values(aws_subnet.koko-pri)[*].id
  }
 output "public_subnet_id" {
    value = values(aws_subnet.koko-pub)[*].id
  }