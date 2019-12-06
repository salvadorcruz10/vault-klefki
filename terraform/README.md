# How to deploy an environment

1. Create an S3 bucket to store the Terraform state
```bash
$ aws s3 mb s3://airtm-terraform-vault-development
```

1. Run [Terraform's init](https://www.terraform.io/docs/commands/init.html) command
```bash
$ terraform init \
    -backend-config='bucket=airtm-terraform-vault-development' \
    -backend-config='key=terraform.tfstate' \
    -backend-config='region=us-east-1'
```

1. Dry-run the execution by running the [Terraform plan](https://www.terraform.io/docs/commands/plan.html) command
```bash
$ terraform plan \
  -var 'environment=development' \
  -var 'acm_certificate_arn=<arn>' \
  -var 'domain_name=<domain>' \
  -var 'vpc_id=<id>'
```

1. Run [Terraform apply](https://www.terraform.io/docs/commands/apply.html) command
```bash
$ terraform apply \
  -var 'environment=development' \
  -var 'acm_certificate_arn=<arn>' \
  -var 'domain_name=<domain>' \
  -var 'vpc_id=<id>'
```
