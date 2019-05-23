
resource "aws_instance" "logstore" {
  count = "${var.instances_logstore["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_logstore["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.rights.nomad_circle_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_logstore["root_hdd_size"]}"
    volume_type = "${var.instances_logstore["root_hdd_type"]}"
  }
  ebs_block_device = {
    volume_size = "${var.instances_logstore["ebs_hdd_size"]}"
    volume_type = "${var.instances_logstore["ebs_hdd_type"]}"
    device_name = "${var.instances_logstore["ebs_hdd_name"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.logstore_realm.id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["ami", "instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-logstore-${count.index}"
  }
}