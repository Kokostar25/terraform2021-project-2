variable "vpc_id" {
    type = string
  
 
}
variable "ec2_keypair" {
    default= "koko-KP"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "ec2_ami" {
    default = "ami-09e67e426f25ce0d7"
}

variable "private_subnet" {
    type = list(string)

}

variable "public_subnet" {
    type = list(string)
    

}


// variable "subnet_ids" {
//     type =list(string)    
// }

variable "vpc_security_group_ids" {
    type = list(string)
}

variable "availability_zones" {
    type = list(string)

    
}

variable "subnet_id_1" {
    type = list(string)
}

variable "subnet_id_2" {
    type = list(string)
}

