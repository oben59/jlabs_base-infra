
resource "aws_s3_bucket" "es_snapshots_bucket" {
  bucket = "${var.target_name}-${var.target_region}-es-snapshots"
  acl    = "private"
  region = "${var.target_region}"

  versioning {
    enabled = true
  }

  tags {
    Name = "${var.target_name}-${var.target_region}-es-snapshots"
  }
}
