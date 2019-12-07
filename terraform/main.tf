
resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster-fargate"
}

# Set up cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.service}-${var.environment}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "app" {
  family                = "${var.service}-${var.environment}-ecs-task"
  container_definitions = "${data.template_file.vault_container.rendered}"

  # Role assumed by the ECS container agent and the Docker daemon
  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn      = "${aws_iam_role.ecs_task_role.arn}"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "${var.container_cpu}"
  memory = "${var.container_memory}"
}

resource "aws_ecs_service" "app" {
  depends_on = ["aws_ecs_task_definition.app"]
  name       = "${var.service}-${var.environment}-ecs-service"

  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    container_name   = "${var.service}-${var.environment}"
    container_port   = "${var.app_port}"
  }

  network_configuration {
    security_groups = ["${module.sg_app.this_security_group_id}"]
    subnets         = "${data.aws_subnet.network.*.id}"
    # If set to false, a NAT Gateway is needed
    # https://github.com/aws/amazon-ecs-agent/issues/1128
    assign_public_ip = "true"
  }
}

resource "aws_alb_target_group" "app" {
  depends_on  = ["aws_alb.public"]
  name        = "${var.service}-${var.environment}"
  port        = "${var.app_port}"
  protocol    = "HTTP"
  vpc_id      = "${data.aws_vpc.network.id}"
  target_type = "ip"

  # https://www.vaultproject.io/api/system/health.html
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,429,472,473"
    timeout             = "3"
    path                = "${var.app_health_check}"
    unhealthy_threshold = "2"
  }
}
