
##
# Entry
#
resource "aws_instance" "entry_instance" {
  count = "${var.instances_entry["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_entry["type"]}"
  iam_instance_profile = "${data.terraform_remote_state.rights.nomad_circle_profile}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_entry["root_hdd_size"]}"
    volume_type = "${var.instances_entry["root_hdd_type"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.elb_front.id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["ami", "instance_type", "root_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-entry-${count.index}"
  }
}

resource "aws_elb" "entry_elb" {
  name = "${replace(data.terraform_remote_state.prebuild.project_name, "ctn-", "")}-www"
  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 30
  cross_zone_load_balancing   = true
  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_ids}",
  ]
  instances = [
    "${aws_instance.entry_instance.id}",
  ]
  security_groups = [
    "${aws_security_group.elb_front.id}",
  ]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  listener {
    instance_port     = 443
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = "${var.ssl_certif}"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "TCP:80"
    interval            = 10
  }
  tags {
    Name = "${replace(data.terraform_remote_state.prebuild.project_name, "ctn-", "")}-svc-elb"
  }
}

resource "aws_route53_record" "entry-elb-record-set" {
  zone_id = "${var.project_hosted_zone_id}"
  name    = "*.svc.${replace(data.terraform_remote_state.prebuild.project_name, "ctn-", "")}.jdxlabs.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.entry_elb.dns_name}"
    zone_id                = "${aws_elb.entry_elb.zone_id}"
    evaluate_target_health = true
  }
}
