module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0" # Use the latest version of the EKS module
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"
  subnet_ids      = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_3.id]
  vpc_id          = aws_vpc.main.id

  # Enable public access to access cluster API via kubectl locally
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_additional_security_group_ids = [aws_security_group.vpc_all_traffic.id]

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small", "t3.micro", "c7i-flex.large"]

    depends_on = [aws_security_group.vpc_all_traffic, aws_vpc.main]
  }

  # Fixed: Moved inside the module block and removed empty ami_type
  eks_managed_node_groups = {
    example = {
      ami_type     = "AL2023_x86_64_STANDARD"  
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 4
      desired_size = 2

      vpc_security_group_ids = [aws_security_group.vpc_all_traffic.id]
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
