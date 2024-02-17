provider "aws"{
region = "us-east-1"
}


#ec2-instance
resource "aws_instance" "instance" {
  ami           = "ami-0c7217cdde317cfec"  # Specify the AMI ID
  instance_type = "t2.micro"      # Specify the instance type
  key_name      = "course=terraform" 
}

#vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}


#security-group
resource "aws_security_group" "securitygroup" {
  name        = "sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}

#security-group-inbound-and-outbound
#inbound-ipv4
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.securitygroup.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#outbound-ipv4
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.securitygroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#public-subnet 
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true 
  availability_zone = "us-east-1f"
  tags = {
    Name = "Main"
  }
}

#gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

#route-table 
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}

#associated-route-table
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.routetable.id
}
