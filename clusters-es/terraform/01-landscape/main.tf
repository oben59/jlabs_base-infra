resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "${data.terraform_remote_state.prebuild.project_name}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }

  # VPC Peering association
  # route {
  #   cidr_block = "${var.vpc_developers_cidr}"
  #   vpc_peering_connection_id = "${var.pcx_id}"
  # }

  tags {
    Name = "Main route table for ${data.terraform_remote_state.prebuild.project_name}"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = "${aws_route_table.main.id}"
  vpc_id = "${aws_vpc.vpc.id}"
}

module "zone_a" {
  source = "zone"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${data.terraform_remote_state.prebuild.project_name}"
  availability_zone = "${data.terraform_remote_state.prebuild.project_region}a"
  public_subnet_cidr = "${var.public_subnet_cidr_a}"
  private_subnet_cidr = "${var.private_subnet_cidr_a}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}

module "zone_b" {
  source = "zone"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${data.terraform_remote_state.prebuild.project_name}"
  availability_zone = "${data.terraform_remote_state.prebuild.project_region}b"
  public_subnet_cidr = "${var.public_subnet_cidr_b}"
  private_subnet_cidr = "${var.private_subnet_cidr_b}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}

module "zone_c" {
  source = "zone"
  vpc_id = "${aws_vpc.vpc.id}"
  vpc_name = "${data.terraform_remote_state.prebuild.project_name}"
  availability_zone = "${data.terraform_remote_state.prebuild.project_region}c"
  public_subnet_cidr = "${var.public_subnet_cidr_c}"
  private_subnet_cidr = "${var.private_subnet_cidr_c}"
  public_gateway_route_table_id = "${aws_route_table.main.id}"
}
