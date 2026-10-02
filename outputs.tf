output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets, where the tasks run"
  value       = module.vpc.public_subnet_ids
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs_cluster.cluster_arn
}

output "service_connect_namespace_arn" {
  description = "Service Connect namespace of the cluster"
  value       = module.ecs_cluster.service_connect_namespace_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URL per service"
  value       = { for name, repo in module.ecr : name => repo.repository_url }
}

output "alb_dns_name" {
  description = "Public address of the platform"
  value       = aws_lb.this.dns_name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix, for request-based autoscaling"
  value       = aws_lb.this.arn_suffix
}

output "alb_listener_arn" {
  description = "HTTP listener where each service adds its rule"
  value       = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  description = "Security group of the ALB, allowed into the tasks"
  value       = aws_security_group.alb.id
}

output "db_endpoint" {
  description = "Writer endpoint of the Aurora cluster"
  value       = module.database.cluster_endpoint
}

output "db_name" {
  description = "Initial database"
  value       = module.database.database_name
}

output "db_master_user_secret_arn" {
  description = "Secrets Manager secret holding the master credentials"
  value       = module.database.master_user_secret_arn
}