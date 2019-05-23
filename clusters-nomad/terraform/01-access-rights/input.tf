variable "target_name" {}
variable "target_region" {}

data "terraform_remote_state" "prebuild" {
  backend = "local"
  config {
    path = "${path.module}/../00-prebuild/${var.target_name}-ctn.${var.target_region}.tfstate"
  }
}
