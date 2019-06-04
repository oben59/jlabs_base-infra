
resource "aws_launch_configuration" "launch_conf" {
  name_prefix = "${var.owner}-${var.env}-${var.region}"
  image_id = "${data.aws_ami.debian.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.owner}-${var.env}-${var.region}"
  associate_public_ip_address = true
  security_groups = [
    "${aws_security_group.asg_ingress.id}"
  ]
  ebs_optimized = false
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  availability_zones = [
    "${var.region}a",
    "${var.region}b"
  ]
  name_prefix = "${var.owner}-${var.env}-${var.region}-asg"
  min_size = "1"
  max_size = "1"
  desired_capacity = "1"
  health_check_grace_period = 300
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = [
    "${data.terraform_remote_state.vpc.public_subnet_id_a}",
    "${data.terraform_remote_state.vpc.public_subnet_id_b}"
  ]
  launch_configuration = "${aws_launch_configuration.launch_conf.name}"
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key = "Name"
    value = "${var.owner}-${var.env}-${var.region}-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg_ingress" {
  name_prefix = "${var.owner}-${var.env}-${var.region}-asg-ingress"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["${var.ingress_cidr}"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
