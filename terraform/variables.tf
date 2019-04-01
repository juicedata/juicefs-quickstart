variable "juicefs_name" {}

variable "s3_bucket_name" {
  default = "juicefs-quickstart"
}

variable "default_name" {
  default = "juicefs-quickstart"
}

variable "default_description" {
  default = "JuiceFS quick start"
}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "aws_availability_zone" {
  default = "ap-northeast-1a"
}

variable "ssh_user" {
  default = "centos"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "checkip_url" {
  default = "http://ipv4.icanhazip.com"
}
