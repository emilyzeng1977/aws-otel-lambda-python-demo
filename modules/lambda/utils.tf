# Archive file
data "archive_file" "zip_src" {
  type        = "zip"
  output_path = var.output_path
  source_dir = var.source_dir
}

resource "aws_s3_bucket_object" "s3_object" {
  bucket = "emily.zeng26"
  key    = "helloworld.zip"
  acl    = "private" # or can be "public-read"
  source = var.output_path
  etag   = filemd5(var.output_path) # Triggers updates when the value changes

  depends_on = [data.archive_file.zip_src]
}
