#create vpc
resource "aws_vpc" "svpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}
#create IGW and attach to VPC
resource "aws_internet_gateway" "sigw" {
  vpc_id = aws_vpc.svpc.id
  tags = {
    Name = "my-igw"
  }
}
#create subnet
resource "aws_subnet" "sps" {
  vpc_id     = aws_vpc.svpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "mypubsubnet"
  }
}
#create route table 
resource "aws_route_table" "srt" {
  vpc_id = aws_vpc.svpc.id
  tags = {
    Name = "my-RT"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sigw.id
  }
}
#create route table association
resource "aws_route_table_association" "dev" {
  route_table_id = aws_route_table.srt.id
  subnet_id      = aws_subnet.sps.id
}
#create security group 
resource "aws_security_group" "ssg" {
  vpc_id      = aws_vpc.svpc.id
  name        = "allow traffic"
  description = "allow inbund traffic and all outbound traffic"
  tags = {
    Name = "my-sample-SG"
  }
  ingress {
    description = "TLS from vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "TLS from vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Launch ec2 instance
resource "aws_instance" "sec2" {
  ami                    = var.aminame
  instance_type          = var.instancetype
  key_name               = var.keyname
  subnet_id              = aws_subnet.sps.id
  vpc_security_group_ids = [aws_security_group.ssg.id]
  tags = {
    Name = "sample_ec2"
  }
}