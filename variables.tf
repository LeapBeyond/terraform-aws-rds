# -----------------------------------------------------------------------------
# data lookups
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

# -----------------------------------------------------------------------------
# items not likely to change much
# -----------------------------------------------------------------------------

# 172.32.0.0 - 172.32.255.255
variable "vpc_cidr" {
  default = "172.32.0.0/16"
}

/* variables to inject via terraform.tfvars */
variable "aws_region" {}

variable "aws_account_id" {}
variable "aws_profile" {}
variable "db_user" {}
variable "db_password" {}
variable "db_port" {}

variable "project_name" {
  default = "aws-rds"
}

variable "rds_properties" {
  type = "map"

  default = {
    "instance_class" = "db.t2.micro"
    "storage_type"   = "gp2"
    "engine"         = "sqlserver-ex"
    "engine_version" = "11.00.7462.6.v1"
    "license_model"  = "license-included"
  }
}

# -----------------------------------------------------------------------------
# items that may change
# -----------------------------------------------------------------------------
variable "tags" {
  type = "map"

  default = {
    "Owner"   = "robert"
    "Project" = "aws-rds"
    "Client"  = "internal"
  }
}

variable "access_cidr" {
  type    = "list"
  default = ["5.148.145.68/32"]
}
