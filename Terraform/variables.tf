variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "private-eks-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cluster_service_cidr" {
  default = "172.20.0.0/16"
}

