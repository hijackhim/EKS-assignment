#module "eks_nodegroup" {
#  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
#  version = "~>20.0"
#
#  cluster_name = module.eks.cluster_name
#  subnet_ids   = module.vpc.private_subnets
#  cluster_service_cidr = var.cluster_service_cidr
#
#  name = "private-ng"
#
# instance_types = ["t3.medium"]
#
#  desired_size = 3
#  min_size     = 3
#  max_size     = 3
#}

module "eks_nodegroup" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~>20.0"

  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data

  subnet_ids   = module.vpc.private_subnets
  cluster_service_cidr = var.cluster_service_cidr

  name = "private-ng"

  instance_types = ["t3.medium"]

  desired_size = 3
  min_size     = 3
  max_size     = 3
}


