# Create Subnets
resource "aws_subnet" "koko-pub" {
  count     =   length(var.public_subnet)  
  vpc_id    =   var.vpc_id
  cidr_block = element(var.public_subnet,count.index)
  availability_zone = element(var.availability_zones, count.index)
   map_public_ip_on_launch = true

  tags = {
    Name = "koko-pub - ${element(var.availability_zones, count.index)}"
  }
}




resource "aws_subnet" "koko-pri" {
  count     =   length(var.private_subnet)  
  vpc_id    =  var.vpc_id 
  cidr_block = element(var.private_subnet,count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false 

  tags = {
    Name = "koko-pri- ${element(var.availability_zones, count.index)}"
  }
}



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
