output "consul_masters" {
  value = ["${aws_instance.consul-masters.*.private_ip}"]
}

output "monitor" {
  value = "${aws_instance.monitor.private_ip}"
}

terraform {
  backend "s3" {}
}
