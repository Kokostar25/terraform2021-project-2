variable "availability_zones" {
  type = list(string)


}

variable "private_subnet" {
  type = list(string)

}

variable "public_subnet" {
  type = list(string)

}


variable "ec2_keypair" {
  default = "koko-KP"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  default = "ami-09e67e426f25ce0d7"
}

// locals {
//   subnets = {
//     koko-pub_1 = {
//       cidr = "10.0.0.0/22"
//       az = "us-east-1a"
//     },
//     koko-pub_2 = {
//       cidr = "10.0.4.0/22"
//       az = "us-east-1b"
//     },
//     koko-pri-1 = {
//       cidr = "10.0.8.0/22"
//       az = "us-east-1a"
//     }
//     koko-pri-2 = {
//       cidr = "10.0.12.0/22"
//       az = "us-east-1b"
//     }
//   }
// }