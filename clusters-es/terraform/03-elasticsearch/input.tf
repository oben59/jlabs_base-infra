variable "target_name" {}
variable "target_region" {}

variable "project_hosted_zone_id" {}
variable "vpc_cidr" {}
variable "vpc_developers_cidr" {}

variable "seed_public_repo_dir" {}
variable "instances_default_public_key" {}
variable "instances_default_private_key" {}

variable "instances_es_masters" {
  type = "map"
}

variable "instances_es_workers" {
  type = "map"
}

variable "slack_webhook" {}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-jessie-amd64-hvm-*"]
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
- 'ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts'
- 'echo "${var.instances_default_public_key}" >> /root/.ssh/id_rsa.pub'
- 'echo "${var.instances_default_private_key}" >> /root/.ssh/id_rsa'
- 'chmod 644 /root/.ssh/id_rsa.pub'
- 'chmod 600 /root/.ssh/id_rsa'
- 'wget ${var.seed_public_repo_dir}'
- 'chmod u+x ./seed-debian-8.sh'
- 'for i in 1 2 3 4 5; do ./seed-debian-8.sh && break || sleep 2; done'
EOF
# - 'git clone git@bitbucket.org:xxx/xxx-es-instance.git'
# - 'cd xxx-es-instance/ && ./setup.sh'
}
data "template_file" "user-data-worker" {
  template = <<EOF
#cloud-config
packages:
- git
runcmd:
- '/bin/mkdir /mnt/data'
- '/sbin/mkfs -t ext4 /dev/xvdb'
- '/bin/mount /dev/xvdb /mnt/data/'
- 'ssh-keyscan -H bitbucket.org >> /root/.ssh/known_hosts'
- 'echo "${var.instances_default_public_key}" >> /root/.ssh/id_rsa.pub'
- 'echo "${var.instances_default_private_key}" >> /root/.ssh/id_rsa'
- 'chmod 644 /root/.ssh/id_rsa.pub'
- 'chmod 600 /root/.ssh/id_rsa'
- 'wget ${var.seed_public_repo_dir}'
- 'chmod u+x ./seed-debian-8.sh'
- 'for i in 1 2 3 4 5; do ./seed-debian-8.sh && break || sleep 2; done'
EOF
# - 'git clone git@bitbucket.org:xxx/xxx-es-instance.git'
# - 'cd xxx-es-instance/ && ./setup.sh'
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

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config {
    bucket = "${var.target_name}-${var.target_region}-tfstate"
    key = "02-bastion.${var.target_name}-${var.target_region}.tfstate"
    region = "${var.target_region}"
  }
}
