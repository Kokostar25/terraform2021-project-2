# Create a VPC

resource "aws_vpc" "koko-vpc" {
cidr_block = var.cidr_block

tags = {
    Name = "koko-vpc"
    }

}
