# General
variable "service" {
  description = "The name of the service"
  default     = "vault"
}

variable "environment" {
  description = "The environment, such as development/stage/production"
  default     = "production"
}

# AWS
variable "aws_profile" {
  type        = "string"
  description = "Profile"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "acm_certificate_arn" {
  description = "The ARN of a certificate in ACM"
}

variable "domain_name" {
  description = "The domain name of an AWS Hosted Zone"
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

# Vault container
variable "container_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "container_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "app_count" {
  description = "Number of containers to run"
  default     = "2"
}

variable "app_image_version" {
  description = "Container image version to run in the ECS cluster"
  default     = "1.0.2"
}

variable "app_port" {
  description = "Port exposed by the Docker image to redirect traffic to"
  default     = "8200"
}

variable "app_health_check" {
  description = "The path for checking the health of the app"
  # Return 200 even if Vault is uninitialized
  # https://www.vaultproject.io/api/system/health.html
  default = "/v1/sys/health?uninitcode=200&sealedcode=200"
}

