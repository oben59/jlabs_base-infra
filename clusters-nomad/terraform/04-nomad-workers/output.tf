
output "nomad_workers_instances" {
  value = ["${aws_instance.nomad_workers.*.private_ip}"]
}

terraform {
  backend "s3" {
  }
}
