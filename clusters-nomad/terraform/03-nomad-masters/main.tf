

resource "aws_security_group" "nomad_masters_group" {
  name_prefix = "nomad-masters-group"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.bastion.bastion_ingress_cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_groups = ["${data.terraform_remote_state.bastion.bastion_realm_id}"]
    description = "usefull for jenkins"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nomad_masters" {
  count = "${var.instances_nomad_masters["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_nomad_masters["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.rights.nomad_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_nomad_masters["root_hdd_size"]}"
    volume_type = "${var.instances_nomad_masters["root_hdd_type"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.nomad_masters_group.id}",
    "${aws_security_group.nomad_realm.id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["ami", "instance_type", "root_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-nomad-master-${count.index}"
  }
}
