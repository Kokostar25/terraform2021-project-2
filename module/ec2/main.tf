

resource "aws_instance" "koko-pub-EC2" {
     
    count       =length(var.public_subnet) 
    ami         = var.ec2_ami
    instance_type = var.instance_type
    key_name = var.ec2_keypair
    subnet_id = var.subnet_id_1[count.index]
    vpc_security_group_ids = [aws_security_group.koko-public-sg.id]
    availability_zone = element(var.availability_zones,count.index)
    associate_public_ip_address = true
    user_data = <<-EOF
            #! /bin/bash
            sudo apt-get update -y
            sudo apt-get upgrade -y
            sudo apt-get install apache2 -y
            sudo systemctl start apache2 
            sudo chmod +x /var/www/html/index.html
            sudo bash -c 'echo Deployed via Terraform > /var/www/html/index.html'
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
    subnet_id = var.subnet_id_2[count.index]
    vpc_security_group_ids = [aws_security_group.koko-private-sg.id]
    availability_zone = element(var.availability_zones, count.index)
  
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
    // cidr_blocks      = ["0.0.0.0/0"]
    security_groups   = [aws_security_group.koko-lb-sg.id]
    

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
    protocol         = "-1"
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
    protocol         = "-1"
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
  subnet_id = var.subnet_id_1[count.index]
  
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
# ALB 
resource "aws_lb" "koko-lb" {
  name               = "koko-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.koko-lb-sg.id]
  subnets            = var.subnet_id_1

  enable_deletion_protection = false   
  tags = {
    Name = "koko-lb"
  }
}

resource "aws_lb_target_group_attachment" "tf-attach-1" {
  target_group_arn = aws_lb_target_group.koko-tg.id
  target_id        = aws_instance.koko-pub-EC2[0].id
  port             = 80
}


resource "aws_lb_target_group_attachment" "tf-attach-2" {
  target_group_arn = aws_lb_target_group.koko-tg.id
  target_id        = aws_instance.koko-pub-EC2[1].id
  port             = 80
}
# Target group for lb

resource "aws_lb_target_group" "koko-tg" {
  name     = "tf-koko-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

health_check {
    port     = 80
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "tf-listener" {
  load_balancer_arn = aws_lb.koko-lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.koko-tg.id
    type             = "forward"
    

  }
}

# Security Group for ALB
resource "aws_security_group" "koko-lb-sg" {
    name = "tf-koko-lb-sg"
    description = "allow HTTPS to tf-koko-elb-sg  Load Balancer (ALB)"
    vpc_id = var.vpc_id
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "koko-lb-sg"
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
  count           = length(var.public_subnet)
  subnet_id       = var.subnet_id_1[count.index]
  route_table_id  = element(aws_route_table.koko-PublicRT.*.id,0)
}


resource "aws_route_table_association" "koko-PriRT" {
  count            = length(var.private_subnet)
  subnet_id        = var.subnet_id_2[count.index]
  route_table_id   = element(aws_route_table.koko-PrivateRT.*.id,1)
}






