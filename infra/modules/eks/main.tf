# EKS Cluster and Node Group Module

# Create IAM role for EKS Cluster
# We need a cluster iam role because it provides the necessary permissions for eks to manage resources on our behalf. 
# Including managing underlying resources, automated cluster operations such as managing network interfaces etc.
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Attach the AmazonEKSClusterPolicy to the cluster role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Create the EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn # Attach the IAM role to the cluster

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure the cluster is created after the IAM role and policy are attached
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

# Create IAM role for EKS Node Group (Worker Nodes)
# This role allows the worker nodes to communicate with the EKS cluster and access other AWS services.
# Mainly, it provides 3 permissions: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach necessary policies to the node role
resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", # Provides permissions for worker nodes to join the cluster
    # Provides permissions for networking and VPC resources, CNI plugin is used for pod networking
    # CNI plugin enables Kubernetes pods to have the same IP address inside the pod as they do on the VPC network,
    # allowing for better network performance and integration with AWS networking features, same as VPC networking.
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Allows nodes to pull container images from Amazon ECR
  ])

  # attach each policy to the node role
  policy_arn = each.value
  role       = aws_iam_role.node.name
}

# Create EKS Node Groups
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  # Ensure the node group is created after the node IAM role and policies are attached
  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]
}