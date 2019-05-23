
resource "aws_security_group" "nomad_realm" {
  name_prefix = "nomad-realm"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "sgri_nomad_realm_backbone" {
  security_group_id   = "${aws_security_group.nomad_realm.id}"
  type                = "ingress"
  from_port           = 4646
  to_port             = 4648
  protocol            = "tcp"
  source_security_group_id = "${aws_security_group.nomad_realm.id}"
}

resource "aws_security_group_rule" "sgri_nomad_realm_consul_agents" {
  security_group_id   = "${aws_security_group.nomad_realm.id}"
  type                = "ingress"
  from_port           = 8000
  to_port             = 9000
  protocol            = "tcp"
  source_security_group_id = "${aws_security_group.nomad_realm.id}"
}

resource "aws_security_group_rule" "sgri_nomad_realm_containers" {
  security_group_id   = "${aws_security_group.nomad_realm.id}"
  type                = "ingress"
  from_port           = 20000
  to_port             = 60000
  protocol            = "tcp"
  source_security_group_id = "${aws_security_group.nomad_realm.id}"
}
