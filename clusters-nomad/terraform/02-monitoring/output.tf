
output "monitor_instances" {
  value = ["${aws_instance.monitor.*.private_ip}"]
}

terraform {
  backend "s3" {
  }
}
