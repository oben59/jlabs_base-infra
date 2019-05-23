
resource "aws_iam_instance_profile" "nomad_profile" {
  name = "${data.terraform_remote_state.prebuild.project_name}-nomad-profile"
  role = "${aws_iam_role.nomad_role.name}"
}

resource "aws_iam_role" "nomad_role" {
  name = "${data.terraform_remote_state.prebuild.project_name}-nomad-role"
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

resource "aws_iam_role_policy" "nomad_policy" {
  name = "${data.terraform_remote_state.prebuild.project_name}-nomad-policy"
  role = "${aws_iam_role.nomad_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "autoscaling:Describe*",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "nomad_app_group" {
  name = "nomad-app-group"
  path = "/"
}

resource "aws_iam_group_policy" "nomad_app_sqs_group_policy" {
  name  = "nomad-app-sqs-group-policy"
  group = "${aws_iam_group.nomad_app_group.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy" "nomad_app_s3_group_policy" {
  name  = "nomad-app-s3-group-policy"
  group = "${aws_iam_group.nomad_app_group.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
