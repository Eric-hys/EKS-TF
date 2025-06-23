data "aws_caller_identity" "current" {}

locals {
  assumed_role_arn = data.aws_caller_identity.current.arn
  iam_role_name    = element(split("/", replace(local.assumed_role_arn, "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/", "")), 0)
}

data "aws_iam_role" "self" {
  name = local.iam_role_name
}

resource "aws_eks_access_entry" "self_exec_role" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.aws_iam_role.self.arn

  type = "STANDARD"

}

resource "aws_eks_access_policy_association" "example" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = data.aws_iam_role.self.arn

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_policy_association" "clusterAdmin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_role.self.arn

  access_scope {
    type       = "cluster"
  }
}
