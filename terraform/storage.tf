resource "aws_s3_bucket" "vault_storage" {
  acl    = "private"
  bucket = "airtm-${var.service}-${var.environment}"

  region = "${var.aws_region}"
}

# https://www.vaultproject.io/docs/configuration/storage/dynamodb.html
resource "aws_dynamodb_table" "vault_storage" {
  name           = "airtm-${var.service}-${var.environment}"

  read_capacity  = 1
  write_capacity = 1

  hash_key       = "Path"
  range_key      = "Key"

  attribute = [{
    name = "Path"
    type = "S"
  }, {
    name = "Key"
    type = "S"
  }]
}

resource "aws_kms_key" "vault_storage" {
  description             = "KMS key for Vault storage"

  # Days after which the key is deleted once the resource is destroyed
  deletion_window_in_days = 10
}
