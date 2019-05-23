output "es_instance_masters_list" {
  value = ["${aws_instance.es-instance-masters.*.private_ip}"]
}

output "es_instance_workers_list" {
  value = ["${aws_instance.es-instance-workers.*.private_ip}"]
}

output "es_dns_name" {
  value = ["${aws_elb.public_es_elb.dns_name}"]
}

output "es_iam_instance_profile" {
  value = "${aws_iam_instance_profile.es_profile.id}"
}

terraform {
  backend "s3" {
  }
}
