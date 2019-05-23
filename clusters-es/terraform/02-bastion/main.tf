resource "aws_key_pair" "bastion_keypair" {
  key_name   = "${data.terraform_remote_state.prebuild.project_name}-bastion"
  public_key = "${var.bastion_default_public_key}"
}

resource "aws_launch_configuration" "bastion_launch_conf" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}"
  image_id = "${data.aws_ami.debian.id}"
  instance_type = "${var.bastion_instance_type}"
  # TODO: IAM PROFILE FOR METRICS (for perl daemon)
  key_name = "${aws_key_pair.bastion_keypair.key_name}"
  associate_public_ip_address = true
  security_groups = [
    "${aws_security_group.bastion_ingress.id}"
  ]
  ebs_optimized = false
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  availability_zones = [
    "${data.terraform_remote_state.prebuild.project_region}a",
    "${data.terraform_remote_state.prebuild.project_region}b",
    "${data.terraform_remote_state.prebuild.project_region}c"
  ]
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-bastion"
  min_size = "1"
  max_size = "1"
  desired_capacity = "1"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = [
    "${data.terraform_remote_state.landscape.public_subnet_id_a}",
    "${data.terraform_remote_state.landscape.public_subnet_id_b}",
    "${data.terraform_remote_state.landscape.public_subnet_id_c}"
  ]
  launch_configuration = "${aws_launch_configuration.bastion_launch_conf.name}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "${data.terraform_remote_state.prebuild.project_name}-bastion"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "bastion_ingress" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-bastion-ingress"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.bastion_ingress_cidr}"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_realm" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-bastion-realm"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_groups = ["${aws_security_group.bastion_ingress.id}"]
  }

  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8500
    to_port = 8500
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8600
    to_port = 8600
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9100
    to_port = 9110
    protocol = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
