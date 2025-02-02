resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "printreveo-${var.environment}-vpc"
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-2"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-main-gw"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags.Name]
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name        = "${var.environment}-ecs-security-group"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [name]
  }
}