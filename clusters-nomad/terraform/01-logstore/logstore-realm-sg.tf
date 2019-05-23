
resource "aws_security_group" "logstore_realm" {
  name_prefix         = "${data.terraform_remote_state.prebuild.project_name}-logstore-realm"
  vpc_id              = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "sgri_logstore_realm_graylog_inputs_rsyslog_udp" {
  security_group_id        = "${aws_security_group.logstore_realm.id}"
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5999
  protocol                 = "udp"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_realm_id}"
}

resource "aws_security_group_rule" "sgri_logstore_realm_graylog_inputs_gelf_tcp" {
  security_group_id        = "${aws_security_group.logstore_realm.id}"
  type                     = "ingress"
  from_port                = 12201
  to_port                  = 12201
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_realm_id}"
}

resource "aws_security_group_rule" "sgri_bastion_realm_rp" {
  security_group_id        = "${aws_security_group.logstore_realm.id}"
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  source_security_group_id = "${data.terraform_remote_state.bastion.bastion_realm_id}"
}
