locals {
  name = "${var.name_prefix}-${var.environment}"

  tags = {
    Project     = var.name_prefix
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "thoughtworks-test-infra"
  }
}

# Red: tareas y ALB en subredes públicas (sin NAT); la base en subredes privadas
module "vpc" {
  source = "github.com/orlando-mt/terraform-aws-vpc?ref=v2.0.0"

  name_prefix = var.name_prefix
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  az_count    = 2

  services = [
    { name = "data" }
  ]

  create_public_subnets = true
  nat_gateway_mode      = "none"
  enable_flow_logs      = var.enable_flow_logs

  common_tags = local.tags
}

module "ecs_cluster" {
  source = "github.com/orlando-mt/terraform-aws-ecs-cluster?ref=v1.0.0"

  cluster_name       = local.name
  container_insights = "disabled"

  fargate_capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [
    { capacity_provider = "FARGATE", weight = 1, base = 1 }
  ]

  # La web llama a la API por nombre dentro del cluster
  create_service_connect_namespace = true

  tags = local.tags
}

module "ecr" {
  source   = "github.com/orlando-mt/terraform-aws-ecr?ref=v1.0.0"
  for_each = toset(["api", "web"])

  repository_name   = "${local.name}-${each.key}"
  force_delete      = true
  max_tagged_images = 5

  tags = local.tags
}

module "database" {
  source = "github.com/orlando-mt/terraform-aws-rds?ref=v1.0.1"

  cluster_name   = "${local.name}-db"
  cluster_type   = "serverlessv2"
  engine_version = var.db_engine_version

  database_name               = "platform"
  master_username             = "platform"
  manage_master_user_password = true

  # 0 ACU: la base se pausa sola cuando nadie la usa
  instance_count             = 1
  serverless_v2_min_capacity = 0.5
  serverless_v2_max_capacity = var.db_max_capacity

  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnet_ids_by_service["data"]
  inbound_cidr_permitted = [var.vpc_cidr]

  # Ajustes de entorno de prueba: sin protección ni snapshot final
  apply_immediately               = true
  backup_retention_period         = 1
  skip_final_snapshot             = true
  deletion_protection             = false
  performance_insights_enabled    = false
  enhanced_monitoring_interval    = 0
  enabled_cloudwatch_logs_exports = []

  tags = local.tags
}