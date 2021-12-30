#This defines your vpc and it's cidr range to be used. Default is 172.22.231.0/24
resource "aws_vpc" "examplevpc" {
  cidr_block = var.vpc_cidr_block
    tags = {
        Name = var.vpctag
    }
}

resource "aws_default_route_table" "defaultrt" {
  default_route_table_id = aws_vpc.examplevpc.default_route_table_id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      Name = "Default-RT"
  }
}

resource "aws_default_security_group" "defaultsg" {
  vpc_id = aws_vpc.examplevpc.id
  ingress {
      protocol = -1
      cidr_blocks = [ "172.22.231.0/24" ]
      from_port = 0
      to_port = 0
  }

  ingress {
      protocol = 6
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      to_port = 22
  }

  egress {
      protocol = -1
      from_port = 0
      to_port = 0
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "DefaultSG"
  }
}

#This defines your public subnet and defaults to 172.22.231.1/26 cidr range
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.examplevpc.id
  cidr_block = var.publicsubnet
  #the following line sets the subnet up with a flag that will assign a public IP to all aws ec2 instances launched with in that subnet ***WARNING***
  map_public_ip_on_launch = true
  tags = {
      Name = "Public-Subnet"
  }
}

#This defines your first private subnet
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.examplevpc.id
    cidr_block = var.privatesubnet1
    map_public_ip_on_launch = false
      tags = {
      Name = "Private-Subnet-1"
  }
}

#This defines your second private subnet
resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.examplevpc.id
    cidr_block = var.privatesubnet2
    map_public_ip_on_launch = false
      tags = {
      Name = "Private-Subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.examplevpc.id
  tags = {
    "Name" = "examplevpc-igw"
  }
}

data "aws_ami" "newami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# output "ami" {
#   value = data.aws_ami.newami
# }

resource "aws_network_interface" "new-ec2-public-interface" {
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_instance" "new-ec2-public" {
  ami = data.aws_ami.newami.id
  instance_type = var.ec2-instance-type
  #key_name = var.keypair
  network_interface {
    network_interface_id = aws_network_interface.new-ec2-public-interface.id
    device_index = 0
  }
}