# ------------------------------------------------------------------------------
# security group constraining access to RDS instance
# ------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  vpc_id      = "${aws_vpc.rds.id}"
  name_prefix = "${var.project_name}"
  description = "allow TSQL"

  tags = "${merge(map("Name", "${var.project_name}-tsql"), var.tags)}"

  ingress {
    from_port   = "${var.db_port}"
    to_port     = "${var.db_port}"
    protocol    = "tcp"
    cidr_blocks = "${concat(var.access_cidr, list(var.vpc_cidr))}"
  }
}

resource "aws_db_subnet_group" "rds" {
  name_prefix = "${var.project_name}"
  subnet_ids  = ["${aws_subnet.rds.*.id}"]
  description = "RDS Subnets"
  tags        = "${var.tags}"
}

resource "aws_db_instance" "rds" {
  depends_on = ["aws_db_subnet_group.rds"]

  identifier_prefix           = "${var.project_name}"
  license_model               = "${var.rds_properties["license_model"]}"
  storage_type                = "${var.rds_properties["storage_type"]}"
  engine                      = "${var.rds_properties["engine"]}"
  engine_version              = "${var.rds_properties["engine_version"]}"
  instance_class              = "${var.rds_properties["instance_class"]}"
  username                    = "${var.db_user}"
  password                    = "${var.db_password}"
  port                        = "${var.db_port}"
  allocated_storage           = 20
  max_allocated_storage       = 100
  backup_retention_period     = 3
  multi_az                    = false
  skip_final_snapshot         = true
  allow_major_version_upgrade = false
  apply_immediately           = true
  copy_tags_to_snapshot       = true
  publicly_accessible         = true
  vpc_security_group_ids      = ["${aws_security_group.rds.id}"]
  db_subnet_group_name        = "${aws_db_subnet_group.rds.id}"

  tags = "${merge(map("Name", "${var.project_name}"), var.tags)}"
}
