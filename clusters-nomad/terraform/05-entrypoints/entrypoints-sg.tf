
##
# ELB - Internet Facing
#
resource "aws_security_group" "elb_front" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-web-elb"
  vpc_id      = "${data.terraform_remote_state.landscape.vpc_id}"
}
resource "aws_security_group_rule" "on_elb_front" {
  security_group_id = "${aws_security_group.elb_front.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "on_elb_front_ssl" {
  security_group_id = "${aws_security_group.elb_front.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "on_elb_front_out" {
  security_group_id = "${aws_security_group.elb_front.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
