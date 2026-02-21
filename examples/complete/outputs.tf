output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the instance"
  value       = module.ec2.instance_private_ip
}

output "instance_state" {
  description = "State of the instance"
  value       = module.ec2.instance_state
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.ec2.security_group_id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = module.ec2.iam_role_arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = module.ec2.kms_key_arn
}

output "root_volume_id" {
  description = "ID of the root EBS volume"
  value       = module.ec2.root_volume_id
}
