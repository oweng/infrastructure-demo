module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.9.0"

  name    = "public-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.demo.arn

      forward = {
        target_group_key = "web"
      }

      #   rules = {
      #     time = {
      #       priority = 10
      #       actions = [{
      #         type             = "forward"
      #         target_group_key = "php-time"
      #       }]
      #       conditions = [{
      #         host_header = {
      #           values = [var.gh_php_time_url]
      #         }
      #       }]
      #     }
      #   }
    }
  }

  target_groups = {
    web = {
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      protocol_version  = "HTTP1"
      create_attachment = false
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/healthcheck.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
