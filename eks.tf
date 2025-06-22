module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.0"

  cluster_name    = "eks-demo"
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # 允許公有與私有都可存取 API Server
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      max_size     = 2
      min_size     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      iam_role_additional_policies = {
        CloudWatchAgent = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }

    eks-pod-identity-agent = {
      most_recent = true
    }

    eks-node-monitoring-agent = {
      most_recent = true
    }

    metrics-server = {
      most_recent = true
    }
    
    amazon-cloudwatch-observability = {
      most_recent = true
      service_account_role_arn = module.cloudwatch_observability_irsa.iam_role_arn
    }
  }

  tags = {
    environment = "dev"
    terraform   = "true"
  }
}

module "ebs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name_prefix         = "ebs-csi-driver"
  attach_ebs_csi_policy    = true

  oidc_providers = {
    main = {
      provider_arn              = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "cloudwatch_observability_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "AmazonCloudWatchObservabilityIRSA"

  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "amazon-cloudwatch/cloudwatch-agent",
        "amazon-cloudwatch/fluent-bit"
      ]
    }
  }
}

