
# create a vpc
resource "aws_vpc" "elohor_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    elohor = "vpc"
  }
}

# create an igw
resource "aws_internet_gateway" "elohor_igw" {
  vpc_id = aws_vpc.elohor_vpc.id

  tags = {
    elohor = "igw"
  }
}

# create a public subnet
resource "aws_subnet" "elohor_public_subnet" {
  vpc_id                  = aws_vpc.elohor_vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-easr-1a"
  map_public_ip_on_launch = true

  tags = {
    elohor = "public_subnet"
  }
}

# create a public subnet2
resource "aws_subnet" "elohor_public_subnet2" {
  vpc_id                  = aws_vpc.elohor_vpc.id
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-easr-1b"

  tags = {
    elohor = "public_subnet2"
  }
}

# create public route table
resource "aws_route_table" "pubic_route_table" {
  vpc_id = aws_vpc.elohor_vpc.id

  tags = {
    elohor = "rt"
  }
}


#create default route 
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.pubic_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.elohor_igw.id

}

# create route table association for public subnert
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.elohor_public_subnet.id
  route_table_id = aws_route_table.pubic_route_table.id
}

# create route table association for public subnert
resource "aws_route_table_association" "public_subnet_assoc2" {
  subnet_id      = aws_subnet.elohor_public_subnet2.id
  route_table_id = aws_route_table.pubic_route_table.id
}

# create security group
resource "aws_security_group" "Webserver-sg" {
  name        = "Webserver"
  description = "sg for frontend webserver"
  vpc_id      = aws_vpc.elohor_vpc.id

  ingress {
    description = "NGINX"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    elohor = "webserver-sg"
  }
}
