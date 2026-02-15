output "cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "nodegroup_name" {
  value = module.eks_nodegroup.node_group_id
}

