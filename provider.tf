provider "aws" {
  region = var.region

  default_tags {
    tags = {
      owner            = "demo app"
      environment      = var.tag_environment
      TerraformManaged = "true"
    }
  }
}
