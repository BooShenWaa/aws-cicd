resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "pipeline-artifacts-boosh"
  acl    = "private" 
}