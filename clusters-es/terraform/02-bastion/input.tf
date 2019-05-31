variable "target_name" {}
variable "target_region" {}

variable "seed_public_repo_dir" {}
variable "bastion_default_public_key" {}
variable "bastion_ingress_cidr" {
  type = "list"
}

variable "bastion_instance_type" {
  default = "t2.medium"
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["379101102735"] # Debian Project
}

data "template_file" "user-data" {
  template = <<EOF
#cloud-config
packages:
- git
runcmd:
  - 'wget ${var.seed_public_repo_dir}'
  - 'chmod u+x ./seed-debian-9.sh'
  - 'for i in 1 2 3 4 5; do ./seed-debian-9.sh && break || sleep 2; done'
EOF
}

data "terraform_remote_state" "prebuild" {
  backend = "local"
  config {
    path = "${path.module}/../00-prebuild/${var.target_name}.${var.target_region}.tfstate"
  }
}

data "terraform_remote_state" "landscape" {
  backend = "s3"
  config {
    bucket = "${var.target_name}-${var.target_region}-tfstate"
    key = "01-landscape.${var.target_name}-${var.target_region}.tfstate"
    region = "${var.target_region}"
  }
}
