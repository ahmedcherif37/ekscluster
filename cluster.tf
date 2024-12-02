resource "aws_security_group" "eks-ekssg" {
  name = "eks-ekssg"
  description = "eks-ekssg"
  vpc_id = aws_vpc.eks-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}

resource "aws_eks_cluster" "eks_eks" {
  name = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks-subnet-public-1.id, aws_subnet.eks-subnet-public-2.id]
    security_group_ids = [aws_security_group.eks-ekssg.id]
  }
}

data "tls_certificate" "cluster_tls" {
  url = aws_eks_cluster.eks_eks.identity[0].oidc[0].issuer
}

resource "aws_eks_node_group" "group-nodes" {
  cluster_name    = aws_eks_cluster.eks_eks.name
  node_group_name = "group-nodes"
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = [aws_subnet.eks-subnet-public-1.id, aws_subnet.eks-subnet-public-2.id]
  instance_types   = ["t3.large"]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-node-AmazonEBSCSIDriverPolicy,
  ]
}
