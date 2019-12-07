# vault-klefki

Generic solution to deploy Vault on ECS

###Prerequisites on specified region

- VPC 
- Route53 Domain
- Certificate

###Terraform version
0.12.6

### How to deploy an environment

- Create an S3 bucket to store the Terraform state,
```bash
$ aws s3 mb s3://airtm-terraform-vault-development-test
```

- Run [Terraform's init](https://www.terraform.io/docs/commands/init.html) command with its configuration file
```bash
$ terraform init -reconfigure -backend-config=backend-vars 
```

- Dry-run the execution by running the [Terraform plan](https://www.terraform.io/docs/commands/plan.html) command
```bash
$ terraform plan -var-file=dev.tfvars 
```

- Run [Terraform apply](https://www.terraform.io/docs/commands/apply.html) command to build your infrastructure
```bash
$ terraform apply -var-file=dev.tfvars 
```