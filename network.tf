data "aws_availability_zones" "available" {
  state = "available"
}

#vpc 
resource "aws_vpc" "eks-vpc" {
cidr_block = "10.23.0.0/16"
enable_dns_support = "true" #gives you an internal domain name
enable_dns_hostnames = "true" #gives you an internal host name
#enable_classiclink = "false"
instance_tenancy = "default"
tags = {
Name = "eks-vpc"
}
}

# subnet pub 1
resource "aws_subnet" "eks-subnet-public-1" {
    vpc_id = "${aws_vpc.eks-vpc.id}"
    cidr_block = "10.23.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[0] 
    tags = {
        Name = "eks-subnet-public-1"
    }
}

# subnet pub 2
resource "aws_subnet" "eks-subnet-public-2" {
    vpc_id = "${aws_vpc.eks-vpc.id}"
    cidr_block = "10.23.2.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = data.aws_availability_zones.available.names[1] 
    tags = {
        Name = "eks-subnet-public-2"
    }
}

# subnet priv 1
resource "aws_subnet" "eks-subnet-priv-1" {
    vpc_id = "${aws_vpc.eks-vpc.id}"
    cidr_block = "10.23.3.0/24"
    availability_zone = data.aws_availability_zones.available.names[0] 
    tags = {
        Name = "eks-subnet-priv-1"
    }
}

# subnet priv 2
resource "aws_subnet" "eks-subnet-priv-2" {
    vpc_id = "${aws_vpc.eks-vpc.id}"
    cidr_block = "10.23.4.0/24"
    availability_zone = data.aws_availability_zones.available.names[1] 
    tags = {
        Name = "eks-subnet-priv-2"
    }
}

# internet gateway
resource "aws_internet_gateway" "eks-igw" {
    vpc_id = "${aws_vpc.eks-vpc.id}"
    tags = {
        Name = "eks-igw"
    }
}

##### NAT #####
resource "aws_eip" "eks-nateip" {
    tags = {
        "Name": "eks-nateip"
    }
}

resource "aws_nat_gateway" "eks-nat" {
  allocation_id = aws_eip.eks-nateip.id
  subnet_id = aws_subnet.eks-subnet-public-1.id
  depends_on = [aws_internet_gateway.eks-igw]

  tags = {
    "Name": "eks-nat"
  }
}

############### ROUTE #################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    "Name": "route-igw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks-nat.id
  }

  tags = {
    "Name": "route-nat"
  }
}

resource "aws_route_table_association" "eks-subnet-public-1" {
  subnet_id = aws_subnet.eks-subnet-public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "eks-subnet-public-2" {
  subnet_id = aws_subnet.eks-subnet-public-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "eks-subnet-priv-1" {
  subnet_id = aws_subnet.eks-subnet-priv-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "eks-subnet-priv-2" {
  subnet_id = aws_subnet.eks-subnet-priv-2.id
  route_table_id = aws_route_table.private.id
}