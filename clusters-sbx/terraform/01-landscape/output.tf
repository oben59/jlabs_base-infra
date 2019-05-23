output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_id_a" {
  value = "${module.zone_a.public_subnet_id}"
}

output "public_subnet_id_b" {
  value = "${module.zone_b.public_subnet_id}"
}

output "public_subnet_id_c" {
  value = "${module.zone_c.public_subnet_id}"
}

output "private_subnet_id_a" {
  value = "${module.zone_a.private_subnet_id}"
}

output "private_subnet_id_b" {
  value = "${module.zone_b.private_subnet_id}"
}

output "private_subnet_id_c" {
  value = "${module.zone_c.private_subnet_id}"
}

output "public_subnet_ids" {
  value = [
    "${module.zone_a.public_subnet_id}",
    "${module.zone_b.public_subnet_id}",
    "${module.zone_c.public_subnet_id}"
  ]
}

output "private_subnet_ids" {
  value = [
    "${module.zone_a.private_subnet_id}",
    "${module.zone_b.private_subnet_id}",
    "${module.zone_c.private_subnet_id}"
  ]
}

terraform {
  backend "s3" {}
}
