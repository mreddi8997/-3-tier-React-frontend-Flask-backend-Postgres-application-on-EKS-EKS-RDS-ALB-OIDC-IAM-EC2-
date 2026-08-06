output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_status" {
  description = "The status of the EKS cluster"
  value       = module.eks.cluster_status
}
