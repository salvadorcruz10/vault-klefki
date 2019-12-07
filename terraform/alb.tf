module "sg_alb" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.service}-${var.environment}-alb"
  description = "Access to ${var.app_port} from anywhere"
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
  egress_with_cidr_blocks = [
    {
      from_port   = "${var.app_port}"
      to_port     = "${var.app_port}"
      protocol    = "tcp"
      description = "${var.service} port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

# Single load balancer for both Vault services
resource "aws_alb" "public" {
  name            = "${var.service}-${var.environment}"
  internal        = false
  idle_timeout    = "300"
  security_groups = ["${module.sg_alb.this_security_group_id}"]
  subnets = "${data.aws_subnet.network.*.id}"
}

# DNS record
resource "aws_route53_record" "app" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${var.service}-${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.public.dns_name}"
    zone_id                = "${aws_alb.public.zone_id}"
    evaluate_target_health = true
  }
}

# More information about SSL policy:
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html
resource "aws_alb_listener" "public" {
  load_balancer_arn = "${aws_alb.public.arn}"
  port              = "${var.app_port}"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = "${var.acm_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}
