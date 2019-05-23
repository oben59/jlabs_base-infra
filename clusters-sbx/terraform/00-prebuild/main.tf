
resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "${var.team}-${var.env}-${var.region}-tfstate"
  acl    = "private"
  region = "${var.region}"

  versioning {
    enabled = true
  }

  tags {
    Name = "${var.target_name}-${var.target_region}-tfstate"
  }
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name           = "${var.target_name}-${var.target_region}-tfstate-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled = false
  }

  tags {
    Name        = "${var.target_name}-${var.target_region}-tfstate-lock"
  }
}
