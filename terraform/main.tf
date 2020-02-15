provider "aws" {
  version = "~> 2.7"
  region  = var.aws_region
}

provider "http" {
  version = "~> 1.0"
}

locals {
  name = "juicefs-${var.juicefs_name}"
}

resource "aws_default_vpc" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "this" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = data.aws_availability_zones.available.names[count.index]
}

module "s3_buckets" {
  source = "git::https://github.com/terraless/terraform-aws-less.git//modules/s3-buckets"

  buckets                     = ["juicefs-${var.juicefs_name}"]
  allow_full_access_iam_roles = [module.iam_role.name]
}

module "iam_role" {
  source = "git::https://github.com/terraless/terraform-aws-less.git//modules/iam-role"

  name = local.name
  trusted_entities = {
    "Service" : [
      "ec2.amazonaws.com"
    ]
  }
}

resource "aws_instance" "this" {
  count = length(data.aws_availability_zones.available.names)

  ami           = data.aws_ami.centos7.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.id
  key_name                    = aws_key_pair.this.key_name

  subnet_id = aws_default_subnet.this[count.index].id
  vpc_security_group_ids = [
    module.ssh_servers_security_group.this_security_group_id,
  ]

  tags = {
    Name = "${local.name}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

data "aws_ami" "centos7" {
  # https://wiki.centos.org/Cloud/AWS

  owners = ["aws-marketplace"]

  most_recent = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = local.name
  public_key = file(var.ssh_public_key)
}

resource "aws_iam_instance_profile" "this" {
  name = local.name
  role = module.iam_role.name
}

data "http" "checkip" {
  url = var.checkip_url
}

module "ssh_servers_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.4.0"

  name        = local.name
  description = var.description
  vpc_id      = aws_default_vpc.this.id

  ingress_cidr_blocks = ["${chomp(data.http.checkip.body)}/32"]
}

data "template_file" "ansible_inventory" {
  count = length(data.aws_availability_zones.available.names)

  template = "juicefs-$${hostname} ansible_host=$${public_ip} ansible_user=centos ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

  vars = {
    hostname  = data.aws_availability_zones.available.names[count.index]
    public_ip = aws_instance.this.*.public_ip[count.index]
    index     = count.index
  }
}
