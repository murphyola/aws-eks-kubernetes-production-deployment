module "ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "ebs-csi"

  attach_aws_ebs_csi_policy = true

  associations = {
    ebs = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = {
    Project     = local.project_name
    Environment = local.environment
  }
}
