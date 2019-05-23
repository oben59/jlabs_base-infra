output "logstore_instances" {
  value = ["${aws_instance.logstore.*.private_ip}"]
}

output "logstore_realm_sg" {
  value = "${aws_security_group.logstore_realm.id}"
}

terraform {
  backend "s3" {
  }
}
