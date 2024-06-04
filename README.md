# Infrastructure Demo

This project does the following:
- builds a vpc (10.0.0.0/16)
- creates 4 subnets, 2 public and 2 private
- creates a public-facing ALB
- creates an ASG for the ec2 instance.  I did this as a best practice to make sure uptime is optimal in the event of an instance failure
- As part of the ASG, also created a role/policy in the event we need access to the ec2 instance, which would be available via SSM
- creates the security groups for the ALB as well as the ec2 instance.  The ec2 sg has limited access only allowing traffic from the ALB security group 
- creates a self-signed cert that is uploaded to ACM, to be used by the ALB
- and outputs a few things for testing

## Challenges/Assumptions
- As always, setting up terraform in a new account can lead to a "chicken or the egg" scenario.  Terragrunt helps a ton with this as it will create your state bucket and terraform dynamodb lock table for you.  In this case, I wrote a quick little bash script `backend_scripts/install_backend.sh`.  Its not ideal, but it does solve the issue of having a state bucket and dynamodb lock table.  Other solutions are to use terraform for this, but it still involves a two step process which then you have to move state around anyways.  I took the easier route here.
- With the ASG, you really don't have access to ec2 instance information that is readily available to lookup.  In this case, The output for the IP address has to wait until the ASG module is done, so the ec2 instance can be looked up.  Now this accounts for the point in time ec2 instance running.  If the instance were to get terminated, the output would be outdated and need to be re-ran to get the new IP.
- Permissions.  Since keys are needed for github actions (or Roles if you have self-hosted runners in your VPC) there is an assumption that the keys/Role have the permissions needed to create the needed infrastructure.  Due to the nature of Terraform and what it can all manage,this tends to be Admin rights, or a collection of rather broad permissions.

## Deployment
This deployment doesn't use workspaces, but rather a very flat file system approach.  All files for all environments could sit right in the repo root. 

Deployment steps are:

Terraform init.  This is using our "demo" backend parameters:


`terraform init -backend-config=demo.config.tfbackend`

Terraform validate to be sure everything checks out:


`terraform validate`

Terraform Plan to see what all we are about to build.  This is using our "demo" tfvars file which could also be dev/stage/prod:


`terraform plan -var-file=demo.tfvars`

Terraform Apply to execute our build.  You will be asked to verify what is all being created, "yes" is the olny option to continue:


`terraform apply -var-file=demo.tfvars`

Terraform destroy.  Finally when all is done, we can clean up all resources created:


`terraform destroy -var-file=demo.tfvars`


Verifying the setup:
- once the Terraform Apply is done, you will have 2 outputs, 1 for the public ALB DNS Name (HTTP will redirect to HTTPS), 2 an output of the ec2 instance IP address that can be verified in the Console.  These outputs are also documented below.


## Testing
I tired to be as thorough as possible in regards to deploying the environment.  As far as testing the deployments:

| deployment type        | tested           | passing  |
| ------------- |:-------------:| -----:|
| locally      | yes | yes |
| github action      | yes      | yes |
| gitlab pipeline | no      |    N/A |


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.52.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | 9.9.0 |
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | 7.6.0 |
| <a name="module_demo_web_sg"></a> [demo\_web\_sg](#module\_demo\_web\_sg) | terraform-aws-modules/security-group/aws | 5.1.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.8.1 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [tls_private_key.demo](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.demo](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.demo_site](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_instances.demo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"demo"` | no |
| <a name="input_nat_node_count"></a> [nat\_node\_count](#input\_nat\_node\_count) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_tag_environment"></a> [tag\_environment](#input\_tag\_environment) | n/a | `string` | n/a | yes |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | n/a | yes |
| <a name="input_vpc_dnsnames"></a> [vpc\_dnsnames](#input\_vpc\_dnsnames) | n/a | `bool` | n/a | yes |
| <a name="input_vpc_dnssupport"></a> [vpc\_dnssupport](#input\_vpc\_dnssupport) | n/a | `string` | n/a | yes |
| <a name="input_vpc_enable_nat_gateway"></a> [vpc\_enable\_nat\_gateway](#input\_vpc\_enable\_nat\_gateway) | n/a | `bool` | n/a | yes |
| <a name="input_vpc_enable_vpn_gateway"></a> [vpc\_enable\_vpn\_gateway](#input\_vpc\_enable\_vpn\_gateway) | n/a | `bool` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | n/a | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_vpc_reuse_nat_ips"></a> [vpc\_reuse\_nat\_ips](#input\_vpc\_reuse\_nat\_ips) | n/a | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_endpoint"></a> [alb\_endpoint](#output\_alb\_endpoint) | Public ALB DNS Name |
| <a name="output_ec2_ip_address"></a> [ec2\_ip\_address](#output\_ec2\_ip\_address) | EC2 IP Address |
<!-- END_TF_DOCS -->
