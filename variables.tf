variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix used to name every resource"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "enable_flow_logs" {
  description = "Send VPC flow logs to CloudWatch"
  type        = bool
  default     = false
}

variable "db_engine_version" {
  description = "Aurora PostgreSQL version. Scaling to 0 ACU needs 16.3+ or 17.4+"
  type        = string
}

variable "db_max_capacity" {
  description = "Aurora Serverless v2 maximum ACUs"
  type        = number
  default     = 1
}

variable "alb_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}