variable "juicefs_name" {}

variable "description" {
  default = "JuiceFS quick start"
}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "ssh_user" {
  default = "centos"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "checkip_url" {
  default = "http://ifconfig.co"
}
