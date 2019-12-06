data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Role assumed by the ECS agent to:
# - pull container image from ECR
# - write logs in CloudWatch
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role-${var.service}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role       = "${aws_iam_role.ecs_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Role assumed by the Vault container
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role-${var.service}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task.json}"
}

resource "aws_iam_role_policy" "ecs_task_role" {
  name = "${var.service}-${var.environment}"
  role = "${aws_iam_role.ecs_task_role.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.vault_storage.arn}",
        "${aws_s3_bucket.vault_storage.arn}/*"
      ]
    },
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_kms_key.vault_storage.arn}"
      ]
    },
    {
      "Action": [
        "dynamodb:DescribeLimits",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeReservedCapacityOfferings",
        "dynamodb:DescribeReservedCapacity",
        "dynamodb:ListTables",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:CreateTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:GetRecords",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.vault_storage.arn}"
      ]
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_cloudwatch_log_group.app.arn}:*"
      ]
    },
    {
      "Action": [
        "ec2:DescribeNetworkInterfaces"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}
