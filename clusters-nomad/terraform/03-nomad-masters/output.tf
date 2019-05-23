
output "nomad_masters_instances" {
  value = ["${aws_instance.nomad_masters.*.private_ip}"]
}

output "nomad_realm_sg" {
  value = "${aws_security_group.nomad_realm.id}"
}

terraform {
  backend "s3" {
  }
}
