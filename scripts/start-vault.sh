#!/usr/bin/dumb-init /bin/sh
set -e

# https://github.com/hashicorp/docker-vault/blob/master/0.X/docker-entrypoint.sh
# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint-v2.html
if [ -z "${VAULT_API_ADDR}" ]; then
  private_ip="$(curl -s http://169.254.170.2/v2/metadata | jq -r .Containers[0].Networks[0].IPv4Addresses[0])"
  public_ip="$(aws ec2 describe-network-interfaces --filters "Name=private-ip-address,Values=${private_ip}" | jq -r .NetworkInterfaces[0].Association.PublicIp)"
  export VAULT_API_ADDR="http://${public_ip}:8200"
  export VAULT_CLUSTER_ADDR="https://${private_ip}:8201"
fi

echo "Vault advertises api_addr=${VAULT_API_ADDR}"
echo "Vault advertises cluster_addr=${VAULT_CLUSTER_ADDR}"

# Starts Vault
sh -c 'vault server -config=/etc/vault/vault_server.hcl'
