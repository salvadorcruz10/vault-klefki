module "sg_app" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.service}-${var.environment}-container"
  description = "Access to ${var.service} port from ${module.sg_alb.this_security_group_name}"
  vpc_id      = "${data.aws_vpc.network.id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = "${var.app_port}"
      to_port     = "${var.app_port}"
      protocol    = "tcp"
      description = "${var.service} port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      from_port   = "${var.app_port}"
      to_port     = "${var.app_port}"
      protocol    = "tcp"
      description = "${var.service} port"

      source_security_group_id = "${module.sg_alb.this_security_group_id}"
    },
    {
      from_port   = "8201"
      to_port     = "8201"
      protocol    = "tcp"
      description = "${var.service} port used by the HA cluster"

      source_security_group_id = "${module.sg_app.this_security_group_id}"
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
  egress_rules  = ["all-all"]
}
