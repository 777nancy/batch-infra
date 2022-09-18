resource "aws_vpc" "batch_infra_vpc" {
  cidr_block = var.cider
  tags = {
    "Name" = "${var.system}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.batch_infra_vpc.id
  cidr_block        = var.public_subnet.cidr_block
  availability_zone = var.public_subnet.availability_zone
  tags = {
    "Name" = "${var.system}-public-subnet"
  }
  depends_on = [
    aws_vpc.batch_infra_vpc
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.batch_infra_vpc.id
  tags = {
    "Name" = "${var.system}-igw"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.batch_infra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "${var.system}-rtb"
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table_association" "rtb-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtb.id
  depends_on = [
    aws_route_table.rtb,
    aws_subnet.public_subnet
  ]
}

resource "aws_security_group" "sg" {
  name        = "${var.system}-sg"
  description = "${var.system} security group"
  vpc_id      = aws_vpc.batch_infra_vpc.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.system}-sg"
  }
  depends_on = [
    aws_vpc.batch_infra_vpc
  ]
}
