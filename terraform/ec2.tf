locals {}

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
  key_name   = "${var.default_name}"
  public_key = "${file(var.ssh_public_key)}"
}

resource "aws_instance" "this" {
  count = "${length(data.aws_availability_zones.available.names)}"

  ami           = "${data.aws_ami.centos7.id}"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.this.id}"
  key_name                    = "${aws_key_pair.this.key_name}"
  subnet_id                   = "${element(aws_default_subnet.this.*.id, count.index)}"

  vpc_security_group_ids = [
    "${module.ssh_servers_security_group.this_security_group_id}",
  ]

  tags = {
    Name = "${var.default_name}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

module "ssh_servers_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "2.10.0"

  name        = "${var.default_name}"
  description = "${var.default_description}"
  vpc_id      = "${aws_default_vpc.this.id}"

  ingress_cidr_blocks = ["${chomp(data.http.checkip.body)}/32"]
}

data "template_file" "ansible_inventory" {
  ## Workaround for the error
  ##   value of 'count' cannot be computed
  ## When we use
  ##   count    = "${length(aws_instance.this.*.public_ip)}"
  count = "${length(data.aws_availability_zones.available.names)}"

  template = "juicefs-$${hostname} ansible_host=$${public_ip} ansible_user=centos ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

  vars {
    hostname  = "${data.aws_availability_zones.available.names[count.index]}"
    public_ip = "${aws_instance.this.*.public_ip[count.index]}"
    index     = "${count.index}"
  }
}
