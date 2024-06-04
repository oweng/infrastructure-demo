
## Adding EC2 security group allowing HTTP access from ALB SG
module "demo_web_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.2"
  name        = "demo-web-sg"
  description = "Security group allowing http access from alb"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "demo web traffic"
      source_security_group_id = module.alb.security_group_id
    },
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["http-80-tcp", "https-443-tcp"]
}

## Data lookup to get the most recent amazon linux 2 AMI
data "aws_ami" "demo_site" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.6.0"

  # Autoscaling group
  name = "${var.environment}-web"

  vpc_zone_identifier              = module.vpc.private_subnets
  min_size                         = 0
  max_size                         = 1
  desired_capacity                 = 1
  create_traffic_source_attachment = true
  traffic_source_identifier        = module.alb.target_groups["web"].arn
  traffic_source_type              = "elbv2"
  image_id                         = data.aws_ami.demo_site.id
  instance_type                    = "t4g.micro"
  user_data                        = filebase64("install_nginx.sh")
  create_iam_instance_profile      = true
  iam_role_name                    = "demo-ec2-role"
  iam_role_path                    = "/ec2/"
  iam_role_description             = "IAM role for instance access via SSM"
  security_groups                  = [module.demo_web_sg.security_group_id]
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

## Don't really like this, but since we are using an ASG to make sure we always have an 
## instance running, this will output the private IP for whatever instance is running at
## the time

data "aws_instances" "demo" {
  instance_tags = {
    Name = "demo-web"
  }

  instance_state_names = ["running"]
}
