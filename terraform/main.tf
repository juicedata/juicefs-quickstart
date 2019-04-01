provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"
}

provider "http" {
  version = "~> 1.0"
}

provider "template" {
  version = "~> 2.1"
}

resource "aws_default_vpc" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "this" {
  count = "${length(data.aws_availability_zones.available.names)}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
}

data "http" "checkip" {
  url = "${var.checkip_url}"
}
