locals {
  route_table_ids = module.vpc.private_route_table_ids
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.cidr

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_vpc" "default_vpc" {
  id = var.default_vpc_id
}

data "aws_route_tables" "default_vpc_tables" {
  vpc_id = var.default_vpc_id
}


resource "aws_vpc_peering_connection" "peering_default" {
  depends_on  = [module.vpc]
  peer_vpc_id = module.vpc.vpc_id
  vpc_id      = data.aws_vpc.default_vpc.id

  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "vpc_peering" {
  depends_on = [module.vpc, aws_vpc_peering_connection.peering_default]

  count                     = length(local.route_table_ids)
  route_table_id            = element(local.route_table_ids, count.index)
  destination_cidr_block    = data.aws_vpc.default_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_default.id
}

resource "aws_route" "default_vpc_peering" {
  depends_on                = [module.vpc, aws_vpc_peering_connection.peering_default]
  for_each                  = data.aws_route_tables.default_vpc_tables.ids
  route_table_id            = each.key
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_default.id
}



