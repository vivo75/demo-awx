# sudo yum install -y yum-utils shadow-utils
# sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
# sudo yum -y install terraform

############################## import ##############################


# import {
#   to = aws_vpc.demoawx_vpc
#   id = "vpc-0ae16271e4333ead2"
# }

import {
  to = aws_security_group.demoawx
  id = "sg-054e7c92f0965eb59"
}

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
data "aws_ami" "git01" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["debian-12-arm64-*"]
  }
}

# # ami-0d8270d86f77e72b2
# data "aws_ami" "git01" {
#   most_recent = true
#   owners      = ["071630900071"]
#   filter {
#     name   = "architecture"
#     values = ["arm64"]
#   }
#   filter {
#     name   = "name"
#     values = ["al2023-ami-202*"]
#   }
# }

# Risparmia fino al 90% sui costi di EC2 utilizzando istanze Spot e fino al 72% con AWS Savings Plans. Ciò va ad aggiungersi al risparmio fino al 10% ottenuto ...
# Le istanze Spot di Amazon EC2 ti permettono di sfruttare le capacità EC2 inutilizzate all’interno del cloud AWS. Le istanze Spot sono disponibili con uno sconto pari al 90% rispetto ai prezzi delle istanze on demand. È possibile impiegare le istanze Spot per diverse applicazioni stateless, flessibili e con tolleranza ai guasti, come ad esempio Big Data, carichi di lavoro con container, integrazione e distribuzione continua, server Web, high performance computing (HPC) e carichi di lavoro di test e sviluppo. Le istanze Spot si integrano con altri servizi AWS tra cui Auto Scaling, EMR, ECS, CloudFormation, Data Pipeline e AWS Batch, permettendoti di scegliere come lanciare e mantenere le tue applicazioni in esecuzione sulle istanze Spot.
# Inoltre, puoi anche combinare in modo semplice le istanze Spot con le istanze on demand, le istanze riservate e i Saving Plans così da ottimizzare il costo dei carichi di lavoro senza comprometterne le prestazioni. Grazie alla capacità di ridimensionamento offerta da AWS, le istanze Spot possono offrire la possibilità di ricalibrare le risorse e ridurre i costi per i carichi di lavoro che necessitano tali operazioni. Potrai inoltre ibernare, fermare o terminare le tue istanze Spot quando EC2 riottiene le capacità con due minuti di preavviso. Solo su AWS, hai facile accesso alle capacità di calcolo inutilizzate con una tale libertà di ridimensionamento, permettendoti di risparmiare fino al 90%.
# https://aws.amazon.com/it/ec2/spot/
# https://www.youtube.com/watch?v=mXX1dgmStlo&feature=youtu.be
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html

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
  cidr_block = "172.16.32.0/22"
  enable_dns_hostnames = true
  tags = merge( local.common_tags, { Name = "demoawx" } )
}

resource "aws_subnet" "demoawx_subnet" {
  vpc_id            = aws_vpc.demoawx_vpc.id
  cidr_block        = "172.16.32.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags = merge( local.common_tags, { Name = "demoawx" } )
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

############################## Gitea ##############################

resource "aws_network_interface" "demoawx01" {
  subnet_id   = aws_subnet.demoawx_subnet.id
  private_ips = ["172.16.32.5"]
  tags = local.common_tags
}

resource "aws_instance" "git01" {
  ami = data.aws_ami.git01.id
  key_name = aws_key_pair.deployer.key_name

  #instance_market_options {
  #  market_type = "spot"
  #  spot_options {
  #    instance_interruption_behavior = "stop"
  #    spot_instance_type = "persistent"
  #  }
  #}
  ## aws ec2 describe-instance-type-offerings --filters Name=instance-type,Values=instance-type --region eu-south-1
  ## https://eu-south-1.console.aws.amazon.com/ec2/home?region=eu-south-1#InstanceTypes:
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


############################## XXX ##############################
