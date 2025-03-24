resource "aws_vpc" "vpc-1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-so"
  }
}


## Create Public Subnet
resource "aws_subnet" "sub" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true # Enables automatic public IP assignment  task I

  tags = {
    Name = "public-subnet"
  }
}


##### Task II DAY I
## Create Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "vpc-so-igw"
  }
}


# Create Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Create Route table Associate
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.sub.id
  route_table_id = aws_route_table.public_rt.id
}


# Allow Apache Ports "Security-Group"

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.vpc-1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "apache-sg"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-08b5b3a93ed654d19" # Change based on your AWS region
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.sub.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello From Mohamed Ashraf Ezzeldin : Terraform Task I</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "apache-server"
  }

  depends_on = [aws_security_group.web_sg] # Ensure Security Group is created first
}

##############    another way  #############################
# resource "aws_route_table" "example" {
#   vpc_id = aws_vpc.example.id

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = aws_internet_gateway.example.id
#   }



#   tags = {
#     Name = "example"
#   }
# }
#########################################################
