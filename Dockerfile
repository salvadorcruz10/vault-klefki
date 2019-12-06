FROM vault:1.0.2

# The following environment variables are needed:
# AWS_S3_BUCKET
# AWS_DYNAMODB_TABLE
# VAULT_AWSKMS_SEAL_KEY_ID

# If AWS credentials are not provided via IAM Role, then also:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# These packages are installed for getting both private-
# and public IP in runtime
RUN apk add --no-cache \
  curl \
  jq \
  python3

RUN python3 -m pip install awscli

COPY config/vault.hcl /etc/vault/vault_server.hcl
COPY scripts/start-vault.sh /usr/local/bin/start-vault.sh

RUN chown vault:vault /etc/vault/vault_server.hcl /usr/local/bin/start-vault.sh
USER vault

ENTRYPOINT [ "sh", "-c", "/usr/local/bin/start-vault.sh" ]
