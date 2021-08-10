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
  default = "t2_micro"
}

variable "ec2_ami" {
  default = "ami-09e67e426f25ce0d7"
}

