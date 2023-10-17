# sudo yum install -y yum-utils shadow-utils
# sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
# sudo yum -y install terraform

############################## imports ##############################

# import {
#   to = aws_vpc_ipv6_cidr_block_association.demoawx_vpc
#   id = "vpc-cidr-assoc-0a2b25ff54e0083a6"
# }

############################## initialization ##############################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.19"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-south-1"
}

# ami = "ami-0100bd16cd78243d8"
data "aws_ami" "default" {
  most_recent = true
  owners      = ["136693071363"]
#   filter {
#     name   = "architecture"
#     values = ["amd64"]
#   }
  filter {
    name   = "name"
    values = ["debian-12-amd64-20231013-1532"]
  }
}

data "aws_ami" "default-arm64" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["debian-12-arm64-20231013-1532"]
  }
}

locals {
  common_tags = {
    project       = "Demo ambiente AWX"
    resourceowner = "Francesco.Riosa@kyndryl.com"
    customer      = "any"
  }
}

data "aws_region" "current" {}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOWIYfTtfus0t5kDQ4uAo7/lQVu9zrXzUP09fBf/bPa kyn-aws-01"
}

############################## Network ##############################

resource "aws_vpc" "demoawx_vpc" {
  cidr_block                        = "172.16.32.0/22"
  enable_dns_hostnames              = true
  assign_generated_ipv6_cidr_block  = true
  tags = merge( local.common_tags, { Name = "demoawx" } )
}

resource "aws_internet_gateway" "demoawx" {
  vpc_id = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "demoawx" } )
}

resource "aws_route_table" "main-demoawx" {
  vpc_id = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "main-demoawx" } )
  depends_on = [aws_internet_gateway.demoawx]
}

resource "aws_security_group" "demoawx" {
  name        = "default"
  description = "default VPC security group"
  vpc_id      = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "default" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i001" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "172.16.32.0/22"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  tags = merge( local.common_tags, { Name = "i001" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i002" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "176.107.152.230/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  tags = merge( local.common_tags, { Name = "i002" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i003" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "172.16.32.0/22"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  tags = merge( local.common_tags, { Name = "i003" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i004" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  tags = merge( local.common_tags, { Name = "i004" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i005" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22010
  ip_protocol = "tcp"
  to_port     = 22010
  tags = merge( local.common_tags, { Name = "i005" } )
}

resource "aws_vpc_security_group_ingress_rule" "sg-demoawx-i006" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "176.107.152.230/32"
  from_port   = 6443
  ip_protocol = "tcp"
  to_port     = 6443
  tags = merge( local.common_tags, { Name = "i006" } )
}

resource "aws_vpc_security_group_egress_rule" "sg-demoawx-e001" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 50000
  ip_protocol = "tcp"
  tags = merge( local.common_tags, { Name = "e001" } )
}

resource "aws_vpc_security_group_egress_rule" "sg-demoawx-e002" {
  security_group_id = aws_security_group.demoawx.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 50000
  ip_protocol = "udp"
  tags = merge( local.common_tags, { Name = "e002" } )
}

############################## app network ##############################

resource "aws_subnet" "demoawx-eip" {
  vpc_id            = aws_vpc.demoawx_vpc.id
  cidr_block        = "172.16.32.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = merge( local.common_tags, { Name = "demoawx-eip" } )
}

resource "aws_route_table" "demoawx-eip" {
  vpc_id = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "demoawx-eip" } )
}

resource "aws_route" "demoawx-eip" {
  route_table_id            = aws_route_table.demoawx-eip.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.demoawx.id
  depends_on                = [aws_route_table.demoawx-eip]
}

resource "aws_route_table_association" "demoawx-eip" {
  subnet_id      = aws_subnet.demoawx-eip.id
  route_table_id = aws_route_table.demoawx-eip.id
}

############################## K3S networking ##############################

locals {
  zones = [
    for i in range(0, 3) : {
      availability_zone = "${data.aws_region.current.name}${substr("abcabcabcabcabc", i, 1)}"
      cidr_block        = "172.16.${32 + i + 1}.0/24"
      nat_private_ip    = "172.16.${32 + i + 1}.253"
      name              = "demoawx-${i}"
    }
  ]
}

resource "aws_route_table" "demoawx" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  vpc_id = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "demoawx-${each.value.availability_zone}" } )
}

resource "aws_route" "demoawx-defgw" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  route_table_id            = aws_route_table.demoawx["${each.value.availability_zone}"].id
  destination_cidr_block    = "0.0.0.0/0"
#   nat_gateway_id            = aws_nat_gateway.demoawx["${each.value.availability_zone}"].id
  gateway_id                = aws_internet_gateway.demoawx.id
}

resource "aws_route_table_association" "demoawx-defgw" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  subnet_id      = aws_subnet.demoawx_subnet["${each.value.availability_zone}"].id
  route_table_id = aws_route_table.demoawx["${each.value.availability_zone}"].id
}

resource "aws_subnet" "demoawx_subnet" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  vpc_id            = aws_vpc.demoawx_vpc.id
  cidr_block        = "${each.value.cidr_block}"
  availability_zone = "${each.value.availability_zone}"
  tags = merge( local.common_tags, { Name = "${each.value.name}" } )
}

resource "aws_security_group" "k3s" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  name        = "k3s-${each.value.availability_zone}"
  description = "k3s security group"
  vpc_id      = aws_vpc.demoawx_vpc.id
  tags = merge( local.common_tags, { Name = "k3s-${each.value.availability_zone}" } )
}

resource "aws_vpc_security_group_egress_rule" "sg-k3s-e001" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  security_group_id = aws_security_group.k3s["${each.key}"].id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 50000
  ip_protocol = "tcp"
  tags = merge( local.common_tags, { Name = "e001-${each.value.availability_zone}" } )
}

resource "aws_vpc_security_group_egress_rule" "sg-k3s-e002" {
  for_each = {for z in local.zones: z.availability_zone =>  z}
  security_group_id = aws_security_group.k3s["${each.key}"].id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 50000
  ip_protocol = "udp"
  tags = merge( local.common_tags, { Name = "e002-${each.value.availability_zone}" } )
}

############################## Gitea ##############################

resource "aws_network_interface" "demoawx01" {
  subnet_id   = aws_subnet.demoawx-eip.id
  private_ips = ["172.16.32.5"]
  tags = local.common_tags
}

resource "aws_instance" "git01" {
  ami = data.aws_ami.default-arm64.id
  key_name = aws_key_pair.deployer.key_name

  instance_type = "t4g.small" # gratuita fino al 2023-12-31 (vcpu 2, 2GB, 20%, cred.24/h, net: 5Gb, disk 2.085Mb/s) 0.0192 USD/h
  ## m6g.large   2       8       Solo EBS        Fino a 10       Fino a 4.750 0.0896 USD/h

  network_interface {
    network_interface_id = aws_network_interface.demoawx01.id
    device_index         = 0
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp3"
  }
  tags = merge( local.common_tags, { Name = "git01" } )
}

resource "aws_eip" "git01" {
  instance = aws_instance.git01.id
  domain   = "vpc"
  tags = merge( local.common_tags, { Name = "git01" } )
}

############################## K3S ##############################

locals {
  k3sconfig = [
    for i in range(0, 3) : {
      instance_name = "k3s0${i + 1}"
      instance_volume = "k3s0${i + 1}v001"
      #private_ip = cidrhost("172.16.32.0/24", "${6 + i}")
      private_ip = "172.16.${32 + i + 1}.6"
      availability_zone = "${data.aws_region.current.name}${substr("abcabcabcabcabc", i, 1)}"
    }
  ]
}

locals {
  k3sinstances = flatten(local.k3sconfig)
}

resource "aws_network_interface" "k3s" {
  for_each = {for server in local.k3sinstances: server.instance_name =>  server}
  subnet_id   = aws_subnet.demoawx_subnet["${each.value.availability_zone}"].id
  private_ips = ["${each.value.private_ip}"]
  tags = merge( local.common_tags, { Name = "${each.value.instance_name}" } )
}

resource "aws_eip" "k3s" {
  for_each = {for server in local.k3sinstances: server.instance_name =>  server}
  instance = aws_instance.k3s["${each.value.instance_name}"].id
  domain   = "vpc"
  tags = merge( local.common_tags, { Name = "${each.value.instance_name}" } )
}

resource "aws_ebs_volume" "k3s-v001" {
  for_each = {for server in local.k3sinstances: server.instance_name =>  server}
  availability_zone = "${each.value.availability_zone}"
  size              = 30
  type              = "gp3"
  tags = merge( local.common_tags, { Name = "${each.value.instance_volume}" } )
}

resource "aws_instance" "k3s" {
  for_each = {for server in local.k3sinstances: server.instance_name =>  server}
  ami                     = data.aws_ami.default.id
  availability_zone       = "${each.value.availability_zone}"
  key_name                = aws_key_pair.deployer.key_name
  instance_type           = "t3a.medium"
  network_interface {
    network_interface_id  = aws_network_interface.k3s["${each.key}"].id
    device_index          = 0
  }
  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp3"
  }
  tags = merge( local.common_tags, { Name = "${each.value.instance_name}" } )
}

resource "aws_volume_attachment" "k3s-v001" {
  for_each = {for server in local.k3sinstances: server.instance_name =>  server}
  device_name                     = "/dev/sdd"
  volume_id                       = aws_ebs_volume.k3s-v001["${each.key}"].id
  instance_id                     = aws_instance.k3s["${each.key}"].id
  stop_instance_before_detaching  = true
}

############################## XXX ##############################
