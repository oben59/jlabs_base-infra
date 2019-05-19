output "project_name" {
  value = "${var.target_name}-${var.target_region}"
}

output "project_region" {
  value = "${var.target_region}"
}