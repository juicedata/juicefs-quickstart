locals {
  ssh_private_key = "${substr(var.ssh_public_key, 0, length(var.ssh_public_key)-4)}"
}

output "ssh_commands" {
  value = "${formatlist("ssh -i %s %s@%s", local.ssh_private_key, var.ssh_user, aws_instance.this.*.public_ip)}"
}

output "ansible_inventory" {
  value = "${join("\n", data.template_file.ansible_inventory.*.rendered)}"
}
