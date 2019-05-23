
resource "aws_instance" "monitor" {
  count = "${var.instances_monitor["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_monitor["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.elasticsearch.es_iam_instance_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_monitor["root_hdd_size"]}"
    volume_type = "${var.instances_monitor["root_hdd_type"]}"
  }
  subnet_id = "${data.terraform_remote_state.landscape.private_subnet_id_a}"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["instance_type", "root_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-monitor-${count.index}"
  }
}

resource "aws_instance" "consul-masters" {
  count = "${var.instances_consul_masters["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_consul_masters["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.elasticsearch.es_iam_instance_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_consul_masters["root_hdd_size"]}"
    volume_type = "${var.instances_consul_masters["root_hdd_type"]}"
  }
  subnet_id = "${data.terraform_remote_state.landscape.private_subnet_id_a}"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["instance_type", "root_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-consul-master-${count.index}"
  }
}
