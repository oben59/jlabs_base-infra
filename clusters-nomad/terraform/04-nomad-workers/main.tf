
resource "aws_security_group" "nomad-workers-group" {
  name_prefix = "nomad-workers-group"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.bastion.bastion_ingress_cidr}"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nomad_workers" {
  count = "${var.instances_nomad_workers["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_nomad_workers["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.rights.nomad_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_nomad_workers["root_hdd_size"]}"
    volume_type = "${var.instances_nomad_workers["root_hdd_type"]}"
  }
  ebs_block_device = {
    volume_size = "${var.instances_nomad_workers["ebs_hdd_size"]}"
    volume_type = "${var.instances_nomad_workers["ebs_hdd_type"]}"
    device_name = "${var.instances_nomad_workers["ebs_hdd_name"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.nomad-workers-group.id}",
    "${data.terraform_remote_state.nomad_masters.nomad_realm_sg}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["ami", "instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-nomad-worker-${count.index}"
  }
}
