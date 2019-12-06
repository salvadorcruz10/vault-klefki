ui = true

# https://www.vaultproject.io/docs/configuration/listener/tcp.html
listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable = "true"
}

# https://www.vaultproject.io/docs/configuration/storage/dynamodb.html
# AWS_DYNAMODB_TABLE
ha_storage "dynamodb"{
  ha_enabled = "true"
}

# https://www.vaultproject.io/docs/configuration/storage/s3.html
# AWS_S3_BUCKET
storage "s3" {}

# https://www.vaultproject.io/docs/configuration/seal/awskms.html
# VAULT_AWSKMS_SEAL_KEY_ID
seal "awskms" {}

# mlock prevents memory from being swapped to disk
# disabling mlock because Fargate doesn't allow adding Linux capabilities
disable_mlock = true

# Improvements:
# - telemetry using DataDog
#   https://www.vaultproject.io/docs/configuration/telemetry.html
# - log_level
