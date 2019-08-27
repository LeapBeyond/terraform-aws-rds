terraform {
  backend "s3" {
    region         = "eu-west-2"
    profile        = "lba_robert"
    dynamodb_table = "terraform-state-lock"
    bucket         = "terraform-state20181016155930974600000001"
    key            = "aws-rds"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:410740436769:key/067f39e0-f551-4fb1-9205-401ad170ed6b"
  }
}
