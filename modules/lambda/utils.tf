# Archive file
data "archive_file" "zip_src" {
  type        = "zip"
  output_path = var.zip_file
  source_dir = var.source_dir
}
