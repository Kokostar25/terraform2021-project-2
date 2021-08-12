# Create Subnets
// resource "aws_subnet" "koko-pub_1" {
//   count     =   length(var.public_subnet)  
//   vpc_id    =   var.vpc_id
//   cidr_block = element(var.public_subnet,count.index)
//   availability_zone = element(var.availability_zones, count.index)
//    map_public_ip_on_launch = true

//   tags = {
//     Name = "koko-pub - ${element(var.availability_zones, count.index)}"
//   }
// }

// resource "aws_subnet" "koko-pub_2" {
//   count     =   length(var.public_subnet)  
//   vpc_id    =   var.vpc_id
//   cidr_block = element(var.public_subnet,count.index)
//   availability_zone = element(var.availability_zones, count.index)
//    map_public_ip_on_launch = true

//   tags = {
//     Name = "koko-pub - ${element(var.availability_zones, count.index)}"
//   }
// }



// resource "aws_subnet" "koko-pri_1" {
//   count     =   length(var.private_subnet)  
//   vpc_id    =  var.vpc_id 
//   cidr_block = element(var.private_subnet,count.index)
//   availability_zone = element(var.availability_zones, count.index)
//   map_public_ip_on_launch = false 

//   tags = {
//     Name = "koko-pri- ${element(var.availability_zones, count.index)}"
//   }
// }



// resource "aws_subnet" "koko-pri_2" {
//   count     =   length(var.private_subnet)  
//   vpc_id    =  var.vpc_id 
//   cidr_block = element(var.private_subnet,count.index)
//   availability_zone = element(var.availability_zones, count.index)
//   map_public_ip_on_launch = false 

//   tags = {
//     Name = "koko-pri- ${element(var.availability_zones, count.index)}"
//   }
// }

locals {
  subnets = {
    koko-pub_1 = {
      cidr = "10.0.0.0/22"
      az = "us-east-1a"
    },
    koko-pub_2 = {
      cidr = "10.0.4.0/22"
      az = "us-east-1b"
    },
    koko-pri-1 = {
      cidr = "10.0.8.0/22"
      az = "us-east-1a"
    }
    koko-pri-2 = {
      cidr = "10.0.12.0/22"
      az = "us-east-1b"
    }
  }
}



// locals {
//   public_subnets = {
//     public_1 = aws_subnet.koko-pub_1
//     public_2 = aws_subnet.koko-pub_2
//   }
// }

// locals {
//   private_subnets = {
//     private_1 = aws_subnet.koko-pri_1
//     private_2 = aws_subnet.koko-pri_2
//   }
// }

resource "aws_subnet" "koko-pub" {
  for_each = local.subnets 
  vpc_id    =   var.vpc_id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "koko-pub - ${each.value.az}"
  }
}

resource "aws_subnet" "koko-pri" {
  for_each = local.subnets 
  vpc_id    =   var.vpc_id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "koko-pri - ${each.value.az}"
  }
}