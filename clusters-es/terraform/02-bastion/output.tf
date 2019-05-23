output "bastion_asg" {
  value = "${aws_autoscaling_group.bastion.name}"
}
output "bastion_realm_id" {
  value = "${aws_security_group.bastion_realm.id}"
}
output "bastion_keypair_name" {
  value = "${aws_key_pair.bastion_keypair.key_name}"
}

output "bastion_ingress_cidr" {
  value = ["${var.bastion_ingress_cidr}"]
}

terraform {
  backend "s3" {
  }
}

