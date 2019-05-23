
output "nomad_profile" {
  value = "${aws_iam_instance_profile.nomad_profile.id}"
}

output "nomad_circle_profile" {
  value = "${aws_iam_instance_profile.nomad_circle_profile.id}"
}

terraform {
  backend "s3" {
  }
}
