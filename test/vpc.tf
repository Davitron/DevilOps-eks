module "vpc" {
  source         = "../modules/vpc"
  default_vpc_id = data.aws_vpc.default.id
}