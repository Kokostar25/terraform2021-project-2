
resource "aws_instance" "koko-pub-EC2" {
    
   
    count       =length(var.public_subnet) 
    ami         = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    subnet_id = var.subnet_ids[count.index]
    vpc_security_group_ids = [aws_security_group.koko-public-sg.id]
    availability_zone = element(var.availability_zones,count.index)
    user_data = <<EOF
		        #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
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
		        #! /bin/bash
                sudo apt-get update
                sudo apt-get install -y apache2
                sudo systemctl start apache2
                sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
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

# Internet Gateway

resource "aws_internet_gateway" "koko-gw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "koko-gw"
  }
}

resource "aws_nat_gateway" "koko-nat-gw" {
  count       = 1
  allocation_id = aws_eip.koko-natgw-eip.id
  //subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  subnet_id = var.subnet_ids[count.index]


  tags = {
    Name = "koko-nat-gw"
  }
}

# Elastic IP

resource "aws_eip" "koko-natgw-eip" {
  vpc           = true
  depends_on    = [aws_internet_gateway.koko-gw]

  tags = {
    Name = "koko-eip"
    }
}


# Create Elastic Load Balancer

resource "aws_elb" "koko-elb" {
  availability_zones = var.availability_zones


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

 

  tags = {
    Name = "koko-elb"
  }
}

# Public Route Table

resource "aws_route_table" "koko-PublicRT" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.koko-gw.id

  }

  tags = {
    Name = "koko-PublicRT"
    }
}

# Private Route Table

resource "aws_route_table" "koko-PrivateRT" {
  count           = 1
  vpc_id          = var.vpc_id
  route {
    cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = element(aws_nat_gateway.koko-nat-gw.*.id, 0)
    
   }
tags = {
    Name = "koko-PrivateRT"
    }
}
# Route Table Association

resource "aws_route_table_association" "koko-PubRT" {
  count           = length(var.private_subnet)
  subnet_id       = var.subnet_ids[count.index]
  route_table_id  = element(aws_route_table.koko-PublicRT.*.id,0)
}


resource "aws_route_table_association" "koko-PriRT" {
  count            = length(var.private_subnet)
  subnet_id        = var.subnet_ids[count.index]
  route_table_id   = element(aws_route_table.koko-PrivateRT.*.id,0)
}

//   #NAT Gateway Route Table
// resource "aws_route_table" "koko-natgw-RT" {
//   vpc_id = var.vpc_id
//   route {
//     cidr_block     = "0.0.0.0/0"
//     nat_gateway_id = aws_nat_gateway.koko-nat-gw.id
//   }
//   tags = {
//     Name = "Route Table for NAT Gateway"
//   }
// }

// #NAT Gateway Route Table association
// resource "aws_route_table_association" "koko-natgw-RT" {
//   subnet_id      = aws_subnet.koko-pri.id
//   route_table_id = aws_route_table.koko-natgw-RT.id
// }





