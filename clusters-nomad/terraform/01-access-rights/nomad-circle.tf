
resource "aws_iam_instance_profile" "nomad_circle_profile" {
  name = "${data.terraform_remote_state.prebuild.project_name}-nomad-circle-profile"
  role = "${aws_iam_role.nomad_circle_role.name}"
}

resource "aws_iam_role" "nomad_circle_role" {
  name = "${data.terraform_remote_state.prebuild.project_name}-nomad-circle-role"
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

resource "aws_iam_role_policy" "nomad_circle_policy" {
  name_prefix = "${data.terraform_remote_state.prebuild.project_name}-nomad-circle-policy"
  role = "${aws_iam_role.nomad_circle_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
