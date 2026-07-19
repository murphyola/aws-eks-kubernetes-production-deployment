module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      capacity_type = "ON_DEMAND"
    }
  }

  addons = {
    vpc-cni = {
      before_compute = true
    }

    kube-proxy = {}

    coredns = {}

    eks-pod-identity-agent = {}

    aws-ebs-csi-driver = {}
  }
  tags = {
    Project     = local.project_name
    Environment = local.environment
  }
}
