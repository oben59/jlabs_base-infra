terraform {
  backend "s3" {
    region = "${var.region}"
    bucket = "${var.owner}-${var.env}-${var.region}-tfstate"
    key = "001-vpc"
  }
}
