variable "vpc_cidr_block" {
  type = string
  default = "172.22.231.0/24"
}

variable "vpctag" {
  type = string
  default = "my_example_vpc"
}

variable "publicsubnet" {
  type = string
  default = "172.22.231.0/26"
}

variable "privatesubnet1" {
  type = string
  default = "172.22.231.64/26"
}

variable "privatesubnet2" {
  type = string
  default = "172.22.231.128/26"
}

variable "ec2-instance-type" {
  default = "t2.micro"
}

#  variable "keypair" {
#    type = string
#  }