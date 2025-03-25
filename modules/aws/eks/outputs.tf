output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "node_group_name" {
  value = aws_eks_node_group.eks_cluster_node_group.node_group_name
}

output "node_group_status" {
  value = aws_eks_node_group.eks_cluster_node_group.status
}

output "eks_node_instance_ids" {
  description = "The IDs of the EKS node instances"
  value       = aws_instance.eks_node.*.id
}
