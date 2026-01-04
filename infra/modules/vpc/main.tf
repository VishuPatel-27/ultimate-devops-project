# Create a VPC with public and private subnets, internet gateway, NAT gateways, and route tables.
# Tags are added for EKS cluster integration.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # CIDR block for the VPC
  enable_dns_hostnames = true         # Enable DNS hostnames    
  enable_dns_support   = true         # Enable DNS support 

  tags = {
    Name                                        = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" # Tag for EKS cluster integration
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)      # Number of private subnets to create
  vpc_id            = aws_vpc.main.id                       # VPC ID
  cidr_block        = var.private_subnet_cidrs[count.index] # CIDR block for each private subnet
  availability_zone = var.availability_zones[count.index]   # Availability zone for each subnet

  tags = {
    Name                                        = "${var.cluster_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" # Tag for EKS cluster integration
    "kubernetes.io/role/internal-elb"           = "1"      # Tag for internal ELB role
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)      # Number of public subnets to create
  vpc_id            = aws_vpc.main.id                      # VPC ID
  cidr_block        = var.public_subnet_cidrs[count.index] # CIDR block for each public subnet
  availability_zone = var.availability_zones[count.index]  # Availability zone for each subnet

  map_public_ip_on_launch = true # Enable public IP assignment on launch

  tags = {
    Name                                        = "${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" # Tag for EKS cluster integration
    "kubernetes.io/role/elb"                    = "1"      # Tag for ELB role
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # VPC ID

  tags = {
    Name = "${var.cluster_name}-igw" # Internet Gateway Name
  }
}

# Create elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs) # Number of EIPs to create
  domain = "vpc"                           # EIP domain

  tags = {
    Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
  }
}

# Create NAT Gateways in public subnets
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)   # Number of NAT Gateways to create
  allocation_id = aws_eip.nat[count.index].id       # EIP allocation ID
  subnet_id     = aws_subnet.public[count.index].id # Public subnet ID

  tags = {
    Name = "${var.cluster_name}-nat-${count.index + 1}"
  }
}

# Create route tables for public and private subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # This route directs traffic to the Internet Gateway
  route {
    # This route allows outbound traffic to the internet
    # Means that any traffic destined for outside the VPC will be sent to the internet gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rtb"
  }
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs) # Number of private route tables to create
  vpc_id = aws_vpc.main.id

  # This route directs traffic to the NAT Gateway
  route {
    # This route allows outbound traffic to the internet via the NAT gateway
    # Means that any traffic destined for outside the VPC will be sent to the NAT gateway
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-rtb-${count.index + 1}"
  }
}

# Associate route tables with private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Associate route tables with public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}