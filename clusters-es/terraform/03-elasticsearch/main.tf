resource "aws_iam_instance_profile" "es_profile" {
  name  = "${data.terraform_remote_state.prebuild.project_name}-es-profile"
  role = "${aws_iam_role.es_role.name}"
}

resource "aws_iam_role" "es_role" {
  name = "${data.terraform_remote_state.prebuild.project_name}-es-role"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "es_role_policy" {
  name = "${data.terraform_remote_state.prebuild.project_name}-es-role-policy"
  role = "${aws_iam_role.es_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:Describe*",
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

# public elb
resource "aws_elb" "public_es_elb" {
  name = "${data.terraform_remote_state.prebuild.project_name}-public-es"

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_id_a}",
    "${data.terraform_remote_state.landscape.public_subnet_id_b}",
    "${data.terraform_remote_state.landscape.public_subnet_id_c}"
  ]

  listener {
    lb_port           = 9200
    lb_protocol       = "tcp"
    instance_port     = 9200
    instance_protocol = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9200"
    interval            = 30
  }

  security_groups = [
    "${aws_security_group.es-elb-group.id}"
  ]

  instances                   = ["${aws_instance.es-instance-masters.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  internal                    = false
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-public_es_elb"
  }

  lifecycle {
    create_before_destroy = false
  }
}

# public elb record
resource "aws_route53_record" "es-elb-record-set" {
  zone_id = "${var.project_hosted_zone_id}"
  name    = "es.${data.terraform_remote_state.prebuild.project_name}.jdxlabs.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.public_es_elb.dns_name}"
    zone_id                = "${aws_elb.public_es_elb.zone_id}"
    evaluate_target_health = false
  }
}

# internal elb
resource "aws_elb" "internal_es_elb" {
  name = "${data.terraform_remote_state.prebuild.project_name}-int-es"

  subnets = [
    "${data.terraform_remote_state.landscape.public_subnet_id_a}",
    "${data.terraform_remote_state.landscape.public_subnet_id_b}",
    "${data.terraform_remote_state.landscape.public_subnet_id_c}"
  ]

  listener {
    lb_port           = 9200
    lb_protocol       = "tcp"
    instance_port     = 9200
    instance_protocol = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9200"
    interval            = 30
  }

  security_groups = [
    "${aws_security_group.es-elb-group.id}"
  ]

  instances                   = ["${aws_instance.es-instance-masters.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  internal                    = true
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-internal_es_elb"
  }

  lifecycle {
    create_before_destroy = false
  }
}

# internal elb record
resource "aws_route53_record" "internal-es-elb-record-set" {
  zone_id = "${var.project_hosted_zone_id}"
  name    = "es.internal.${data.terraform_remote_state.prebuild.project_name}.jdxlabs.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.internal_es_elb.dns_name}"
    zone_id                = "${aws_elb.internal_es_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_security_group" "es-group" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-es-members"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
}

resource "aws_security_group_rule" "allow_9200_es_elb" {
  type            = "ingress"

  from_port       = 9200
  to_port         = 9200
  protocol        = "tcp"

  security_group_id = "${aws_security_group.es-group.id}"
  source_security_group_id = "${aws_security_group.es-elb-group.id}"
}

resource "aws_security_group_rule" "allow_9200_es_self" {
  type            = "ingress"

  from_port       = 9200
  to_port         = 9200
  protocol        = "tcp"

  security_group_id = "${aws_security_group.es-group.id}"
  source_security_group_id = "${aws_security_group.es-group.id}"
}

resource "aws_security_group_rule" "allow_9300_es_self" {
  type            = "ingress"

  from_port       = 9300
  to_port         = 9300
  protocol        = "tcp"

  security_group_id = "${aws_security_group.es-group.id}"
  source_security_group_id = "${aws_security_group.es-group.id}"
}

resource "aws_security_group_rule" "allow_es_all" {
  type            = "egress"

  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.es-group.id}"
}

# sg public elb
resource "aws_security_group" "es-elb-group" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-es-elb"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "TCP"
    cidr_blocks = ["${data.terraform_remote_state.bastion.bastion_ingress_cidr}", "${var.vpc_cidr}", "${var.vpc_developers_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "es-elb-group-monitor" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-es-elb-monitor"
  vpc_id = "${data.terraform_remote_state.landscape.vpc_id}"
  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "TCP"
    security_groups = [
      "${data.terraform_remote_state.bastion.bastion_realm_id}"
    ]
  }
}

# ES Instances Masters
resource "aws_instance" "es-instance-masters" {
  count = "${var.instances_es_masters["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_es_masters["type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.es_profile.name}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_es_masters["root_hdd_size"]}"
    volume_type = "${var.instances_es_masters["root_hdd_type"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.es-group.id}",
    "${aws_security_group.es-elb-group-monitor.id}"
  ]
  user_data = "${data.template_file.user-data.rendered}"
  lifecycle {
    ignore_changes = ["instance_type", "root_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-es-instance-master-${count.index}"
  }
}

# ES Instances Workers
resource "aws_instance" "es-instance-workers" {
  count = "${var.instances_es_workers["nb"]}"
  ami = "${data.aws_ami.debian.id}"
  instance_type = "${var.instances_es_workers["type"]}"
  iam_instance_profile = "${aws_iam_instance_profile.es_profile.name}"
  key_name = "${data.terraform_remote_state.bastion.bastion_keypair_name}"
  root_block_device = {
    volume_size = "${var.instances_es_workers["root_hdd_size"]}"
    volume_type = "${var.instances_es_workers["root_hdd_type"]}"
  }
  ebs_block_device = {
    volume_size = "${var.instances_es_workers["ebs_hdd_size"]}"
    volume_type = "${var.instances_es_workers["ebs_hdd_type"]}"
    device_name = "${var.instances_es_workers["ebs_hdd_name"]}"
  }
  subnet_id = "${
    element(
      data.terraform_remote_state.landscape.private_subnet_ids,
      count.index % length(data.terraform_remote_state.landscape.private_subnet_ids)
    )
  }"
  vpc_security_group_ids = [
    "${data.terraform_remote_state.bastion.bastion_realm_id}",
    "${aws_security_group.es-group.id}",
    "${aws_security_group.es-elb-group-monitor.id}"
  ]
  user_data = "${data.template_file.user-data-worker.rendered}"
  lifecycle {
    ignore_changes = ["instance_type", "user_data", "root_block_device", "ebs_block_device"]
  }
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}-es-instance-worker-${count.index}"
  }
}


# Lambda for snapshots

resource "aws_iam_role" "lambda_es_snapshots_role" {
  name = "${data.terraform_remote_state.prebuild.project_name}-lambda-es-snapshots-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_es_snapshots_role_policy" {
  name = "${data.terraform_remote_state.prebuild.project_name}-lambda-es-snapshots-role-policy"
  role = "${aws_iam_role.lambda_es_snapshots_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_es_snapshots" {
  filename = "lambda_es_snapshots.zip"
  function_name = "${data.terraform_remote_state.prebuild.project_name}-lambda-es-snapshots"
  role = "${aws_iam_role.lambda_es_snapshots_role.arn}"
  handler = "main.handler"
  source_code_hash = "${base64sha256(file("lambda_es_snapshots.zip"))}"
  runtime = "python2.7"

  environment {
    variables = {
      es_endpoint = "${aws_instance.es-instance-masters.0.private_ip}"
      es_port = "9200"
      es_s3_repo = "${var.target_name}-${var.target_region}-es-snapshots"
      slack_url = "${var.slack_webhook}"
    }
  }

  vpc_config          = {
    subnet_ids          = ["${data.terraform_remote_state.landscape.private_subnet_ids}"]
    security_group_ids  = ["${data.terraform_remote_state.bastion.bastion_realm_id}"]
  }
}

resource "aws_cloudwatch_event_rule" "es_snapshots_trigger" {
    name = "${data.terraform_remote_state.prebuild.project_name}-es-snapshots-trigger"
    description = "Triggers snapshot periodically"
    schedule_expression = "cron(00 01 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check_lambda_es_snapshots" {
    rule = "${aws_cloudwatch_event_rule.es_snapshots_trigger.name}"
    target_id = "lambda_es_snapshots"
    arn = "${aws_lambda_function.lambda_es_snapshots.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_es_snapshots" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_es_snapshots.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.es_snapshots_trigger.arn}"
}
