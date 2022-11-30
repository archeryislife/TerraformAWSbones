# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# A couple of notes;
# 1.  This is a bear bones setup of a VPC, Public subnet, and two Private subnets. It also contains all the required infrastructure and route tables to make
#     a SSH connection to a single ec2 instance created. Where you want to take this from here is up to you.
# 2.  setup a key pair in the console before running this code, use that key when it calls for user input. Once it comes time to destory you can loose the
#     pair during tear down. 
# 3.  If you prefer to not accept defaults open up the variables.tf file and find "default" and replace with "#default" for any variables you wish to be
#     prompted for.
# 4.  I didn't make this for any particular reason other than to teach myself TF(terraform) and be able to quickly build out infrastructure for testing other stuff. If
#     you have suggestions or want to fork it feel free and have fun!! :)
# 5.  If you are new to TF(terraform) please go watch the following youtube video, it is not mine but is a really good to get beginners started.
#     https://www.youtube.com/watch?v=SLB_c_ayRMo
# 6.  The providers.tf file is setup to be used with shared credentials in the .aws directory in your linux home directory. You will probably want to customize
#     this to your setup before running the code
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#This defines your vpc and it's cidr range to be used. Default is 172.22.231.0/24
resource "aws_vpc" "examplevpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpctag
  }
}

#Define default routing table for any ec2 instance
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

#Define default security group for ec2, assigned ingress of quad 0's and same egress
resource "aws_default_security_group" "defaultsg" {
  vpc_id = aws_vpc.examplevpc.id
  ingress {
    protocol    = -1
    cidr_blocks = ["172.22.231.0/24"]
    from_port   = 0
    to_port     = 0
  }

  ingress {
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DefaultSG"
  }
}

#This defines your public subnet and defaults to 172.22.231.1/26 cidr range
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.examplevpc.id
  cidr_block = var.publicsubnet
  #the following line sets the subnet up with a flag that will assign a public IP to all aws ec2 instances launched with in that subnet ***WARNING***
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}

#This defines your first private subnet, default is 172.22.231.64/26
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.examplevpc.id
  cidr_block              = var.privatesubnet1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet-1"
  }
}

#This defines your second private subnet, default is 172.22.231.128/26
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.examplevpc.id
  cidr_block              = var.privatesubnet2
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet-2"
  }
}

#Setup the Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.examplevpc.id
  tags = {
    "Name" = "examplevpc-igw"
  }
}

#Get the latest Ubuntu 20.04 ami
data "aws_ami" "newami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#Test output to verify correct ami from data block above, comment out when not needed
# output "ami" {
#   value = data.aws_ami.newami
# }

#Apply network interface to public subnet
resource "aws_network_interface" "new-ec2-public-interface" {
  subnet_id = aws_subnet.public_subnet.id
}

#Create the EC2 instance
#!!!!!!!WARNING!!!!!!!    THERE BE DRAGONS HERE
#Be careful in this block, by default the instance is set to t2.micro in the variable, watch your costs if you go larger
#Be really, really, REALLY careful to create a new key pair via the console prior to running this code. I'm not sure what happens if you run
#destroy on existing key pairs you might need else where. 
resource "aws_instance" "new-ec2-public" {
  ami           = data.aws_ami.newami.id
  instance_type = var.ec2-instance-type
  key_name      = var.keypair
  network_interface {
    network_interface_id = aws_network_interface.new-ec2-public-interface.id
    device_index         = 0
  }
  tags = {
      Name = "exampleEC2"
  }
}