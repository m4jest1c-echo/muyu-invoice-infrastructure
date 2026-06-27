# VPC resources will be defined here when network infrastructure is implemented.
resource "aws_vpc" "muyu" {
  cidr_block = var.vpc_cidr
}

# Public subnet resources will be added here for internet-facing components.
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = var.public_subnet_1_cidr
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = var.public_subnet_2_cidr
}

# Private subnet resources will be added here for internal components.
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = var.private_subnet_1_cidr
}
resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.muyu.id
  cidr_block = var.private_subnet_2_cidr
}

# Internet Gateway resources will be added here for public internet access.



# Route Tables will be added here for public and private subnet routing.
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.muyu.id

  # Para salida a internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.muyu.id
  # }

  # tags = {
  #   Name = "muyu"
  # }
}
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.muyu.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.muyu.id
  # }

  # tags = {
  #   Name = "muyu"
  # }
}

resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "private-subnet-1-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.rt_private.id
}
resource "aws_route_table_association" "private-subnet-2-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.rt_private.id
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.muyu.id

}
# Route Table Associations will be added here to attach subnets to routes.





resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet-1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}