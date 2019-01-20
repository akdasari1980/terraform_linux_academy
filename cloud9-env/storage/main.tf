#======storage/main.tf======

# Create a random ID
# S3 Buckets must be unique

# random_id resource docs
# https://www.terraform.io/docs/providers/random/r/id.html
#
# random provider docs
# https://www.terraform.io/docs/providers/random/index.html

resource "random_id" "la_s3_bucket_id" {
    byte_length = 2
}

# Create a bucket

# aws_s3_bucket resource docs
# https://www.terraform.io/docs/providers/aws/d/s3_bucket.html
#
# AWS provider docs
# https://www.terraform.io/docs/providers/aws/index.html

resource "aws_s3_bucket" "tf_code" {
    bucket = "${var.project_name}-${random_id.la_s3_bucket_id.dec}"
    acl = "private"
    force_destroy = true
    tags {
        name = "tf_bucket"
    }
}