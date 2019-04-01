resource "aws_s3_bucket" "this" {
  count = "${var.s3_bucket_name == "" ? 1 : 0}"

  # By default, JuiceFS will use juicefs-<fsname> as data storage bucket
  bucket = "juicefs-${var.juicefs_name}"
}
