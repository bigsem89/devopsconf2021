provider "aws" {
  region = var.aws_region
}

locals {
  cluster_name = "eks-spot-workshop"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = data.aws_subnet_ids.eks_subnets.ids

  tags = {
    Project = "SpotWorkshop"
  }

  vpc_id = var.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 40
  }

  node_groups = {
    spot_group = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1

      instance_types = ["m4.large", "m5.large", "t3.medium", "t2.medium"]
      capacity_type  = "SPOT"
    }
  }
}

data "aws_subnet_ids" "eks_subnets" {
    vpc_id = var.vpc_id
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
