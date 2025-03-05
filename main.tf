# git clone https://github.com/hashicorp-education/learn-terraform-provision-eks-cluster
# https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "deepseek-terraform"
    key            = "deepseek-cluster.tfstate"  # Caminho do state dentro do bucket
    region         = "us-east-2"
  }
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "deepseek-cluster"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {  
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = "deepseek-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = ["g5.2xlarge"]
    disk_size = 200
  }

  eks_managed_node_groups = {
    single = {
      name = "node-group-single"

      create_launch_template = false 
      use_custom_launch_template = false 
      launch_template_name   = ""
      disk_size = 200  # Aqui corrige o tamanho do disco para 200GB

      
      instance_types = ["g5.2xlarge"]  # Usando a instância g5.2xlarge

      min_size     = 1  # Apenas um nó
      max_size     = 1  # Apenas um nó
      desired_size = 1  # Apenas um nó

      remote_access = {
        ec2_ssh_key = "your-ssh-here"
      }
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}