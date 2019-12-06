[
  {
    "name": "${service}-${environment}",
    "image": "${app_image_version}",
    "cpu": ${container_cpu},
    "environment": [
      {
        "name": "AWS_S3_BUCKET",
        "value": "${s3_bucket}"
      },
      {
        "name": "AWS_DYNAMODB_TABLE",
        "value": "${dynamodb_table}"
      },
      {
        "name": "VAULT_AWSKMS_SEAL_KEY_ID",
        "value": "${kms_key_id}"
      }
    ],
    "essential": true,
    "memory": ${container_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${service}-${environment}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ]
  }
]
