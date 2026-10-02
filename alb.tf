# El ALB va con recursos directos: el módulo lb solo admite HTTPS con certificado
# y este entorno de prueba no tiene dominio.

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  description = "Load balancer of ${local.name}"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, { Name = "${local.name}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = toset(var.alb_allowed_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "alb_to_vpc" {
  security_group_id = aws_security_group.alb.id
  description       = "To the tasks inside the VPC"
  ip_protocol       = "-1"
  cidr_ipv4         = var.vpc_cidr

  tags = local.tags
}

resource "aws_lb" "this" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnet_ids

  # La generación de Terraform con el modelo puede tardar más del minuto por defecto
  idle_timeout               = 120
  drop_invalid_header_fields = true

  tags = local.tags
}

# Sin reglas todavía: cada servicio agrega la suya al desplegarse
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{\"message\":\"Not found\"}"
      status_code  = "404"
    }
  }

  tags = local.tags
}