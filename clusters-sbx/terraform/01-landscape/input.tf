variable "target_name" {}
variable "target_region" {}

variable "vpc_cidr" {}
variable "vpc_developers_cidr" {}
# variable "pcx_id" {}
variable "public_subnet_cidr_a" {}
variable "private_subnet_cidr_a" {}
variable "public_subnet_cidr_b" {}
variable "private_subnet_cidr_b" {}
variable "public_subnet_cidr_c" {}
variable "private_subnet_cidr_c" {}

data "terraform_remote_state" "prebuild" {
  backend = "local"
  config {
    path = "${path.module}/../00-prebuild/${var.target_name}.${var.target_region}.tfstate"
  }
}
