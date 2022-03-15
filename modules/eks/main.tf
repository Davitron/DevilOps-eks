locals {

}

module "cluster" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "18.10.0"
  cluster_name = "test"
}