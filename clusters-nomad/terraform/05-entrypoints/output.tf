
output "entry_instance" {
  value = ["${aws_instance.entry_instance.0.private_ip}"]
}
output "entry_public" {
  value = "${aws_instance.entry_instance.0.public_ip}"
}

terraform {
  backend "s3" {
  }
}
