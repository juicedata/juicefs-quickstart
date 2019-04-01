locals {
  s3_bucket_name = "${coalesce(var.s3_bucket_name, aws_s3_bucket.this.id)}"
}

resource "aws_iam_role" "this" {
  name = "${var.default_name}"

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

resource "aws_iam_role_policy" "s3" {
  name = "s3"
  role = "${aws_iam_role.this.id}"

  policy = "${module.s3_access_iam_policy_document.fullaccess_json}"
}

module "s3_access_iam_policy_document" {
  source  = "github.com/yujunz/terraform-aws-iam-policy-document//modules/s3-access"
  buckets = ["${local.s3_bucket_name}"]
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.default_name}"
  role = "${aws_iam_role.this.name}"
}
