data "aws_vpc" "network" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "network" {
  vpc_id = "${data.aws_vpc.network.id}"
}

data "aws_subnet" "network" {
  count = "${length(data.aws_subnet_ids.network.ids)}"
  id    = "${data.aws_subnet_ids.network.ids[count.index]}"
}

data "aws_route53_zone" "domain" {
  name = "${var.domain_name}"
}

data "template_file" "vault_container" {
  template = "${file("${path.module}/templates/vault-container.json.tpl")}"

  vars {
    app_image_version = "${aws_ecr_repository.app.repository_url}:${var.app_image_version}"
    app_port  = "${var.app_port}"

    aws_region = "${var.aws_region}"

    container_cpu    = "${var.container_cpu}"
    container_memory = "${var.container_memory}"

    service     = "${var.service}"
    environment = "${var.environment}"

    dynamodb_table = "${aws_dynamodb_table.vault_storage.id}"
    kms_key_id     = "${aws_kms_key.vault_storage.key_id}"
    s3_bucket      = "${aws_s3_bucket.vault_storage.id}"
  }
}
