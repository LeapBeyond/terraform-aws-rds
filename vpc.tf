# ------------------------------------------------------------------------------
# define the VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "rds" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(map("Name", "${var.project_name}"), var.tags)}"
}

# seal off the default NACL
resource "aws_default_network_acl" "rds" {
  default_network_acl_id = "${aws_vpc.rds.default_network_acl_id}"
  tags                   = "${merge(map("Name", "${var.project_name}-default"), var.tags)}"
}

# seal off the default security group
resource "aws_default_security_group" "rds" {
  vpc_id = "${aws_vpc.rds.id}"
  tags   = "${merge(map("Name", "${var.project_name}-default"), var.tags)}"
}

resource "aws_internet_gateway" "rds" {
  vpc_id = "${aws_vpc.rds.id}"
  tags   = "${merge(map("Name", "${var.project_name}"), var.tags)}"
}

# ------------------------------------------------------------------------------
# define the subnets
# ------------------------------------------------------------------------------
resource "aws_subnet" "rds" {
  count = "${length(data.aws_availability_zones.available.names)}"

  vpc_id                  = "${aws_vpc.rds.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags                    = "${merge(map("Name", "${var.project_name}-public-${count.index}"), var.tags)}"
}

# ------------------------------------------------------------------------------
# route external traffic through the internet gateway
# ------------------------------------------------------------------------------
resource "aws_route_table" "rds" {
  vpc_id = "${aws_vpc.rds.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rds.id}"
  }

  tags = "${merge(map("Name", "${var.project_name}"), var.tags)}"
}

resource "aws_route_table_association" "rds" {
  count = "${length(data.aws_availability_zones.available.names)}"

  subnet_id      = "${element(aws_subnet.rds.*.id, count.index)}"
  route_table_id = "${aws_route_table.rds.id}"
}

# ------------------------------------------------------------------------------
# define NACL for the subnets
# ------------------------------------------------------------------------------

resource "aws_network_acl" "rds" {
  vpc_id     = "${aws_vpc.rds.id}"
  subnet_ids = ["${aws_subnet.rds.*.id}"]
  tags       = "${merge(map("Name", "${var.project_name}"), var.tags)}"
}

resource "aws_network_acl_rule" "ephemeral_out" {
  network_acl_id = "${aws_network_acl.rds.id}"
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "http_out" {
  network_acl_id = "${aws_network_acl.rds.id}"
  rule_number    = 101
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "https_out" {
  network_acl_id = "${aws_network_acl.rds.id}"
  rule_number    = 102
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ephemeral_in" {
  network_acl_id = "${aws_network_acl.rds.id}"
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "sqlserver_in" {
  network_acl_id = "${aws_network_acl.rds.id}"
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${var.db_port}"
  to_port        = "${var.db_port}"
}
