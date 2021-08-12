
resource "aws_instance" "koko-pub-EC2" {
    
   
    count       =length(var.public_subnet) 
    ami         = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    subnet_id = var.subnet_ids[count.index]
    vpc_security_group_ids = [aws_security_group.koko-public-sg.id]
    availability_zone = element(var.availability_zones,count.index)
    user_data = <<EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c "echo my terraform webserver > /var/www/html/index.html"
    EOF

    
  tags = {
    Name = "koko-pub-EC2 - ${element(var.availability_zones,count.index)} "
  }
}


resource "aws_instance" "koko-pri-EC2" {
    count         =length(var.private_subnet) 
    ami           = var.ec2_ami
    instance_type = var.instance_type
    key_name      = var.ec2_keypair
    subnet_id = var.subnet_ids[count.index]
    vpc_security_group_ids = [aws_security_group.koko-private-sg.id]
    availability_zone = element(var.availability_zones, count.index)

     user_data = <<EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c "echo my terraform webserver > /var/www/html/index.html"
    EOF



  tags = {
    Name = "koko-pri-EC2 -${element(var.availability_zones, count.index)} "
  }
}


# Create Security group

resource "aws_security_group" "koko-public-sg" {
  name        = "koko-public-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "inbound rules from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
    
 ingress {
    description      = "inbound rules from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    
  
}

resource "aws_security_group" "koko-private-sg" {
  name        = "koko-private-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

 ingress {
    description      = "inbound rules from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "inbound rules from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    
  


}
