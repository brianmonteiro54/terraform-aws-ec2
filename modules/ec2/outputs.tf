# =============================================================================
# Outputs - EC2 Module
# =============================================================================

# Instance Information
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this[0].id
}

output "instance_state" {
  description = "State of the instance"
  value       = aws_instance.this[0].instance_state
}

output "instance_public_ip" {
  description = "Public IP of instance"
  value       = aws_instance.this[0].public_ip
}

output "instance_private_ip" {
  description = "Private IP of instance"
  value       = aws_instance.this[0].private_ip
}

output "instance_public_dns" {
  description = "Public DNS of instance"
  value       = aws_instance.this[0].public_dns
}

output "instance_private_dns" {
  description = "Private DNS of instance"
  value       = aws_instance.this[0].private_dns
}

# EIP Information
output "eip_id" {
  description = "ID of the Elastic IP"
  value       = try(aws_eip.this[0].id, null)
}

output "eip_public_ip" {
  description = "Public IP of the Elastic IP"
  value       = try(aws_eip.this[0].public_ip, null)
}

output "eip_allocation_id" {
  description = "Allocation ID of the Elastic IP"
  value       = try(aws_eip.this[0].allocation_id, null)
}

# Security Group
output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

# IAM
output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "iam_instance_profile_name" {
  description = "Name of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

# KMS
output "kms_key_id" {
  description = "KMS key ID"
  value       = local.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = local.kms_key_id
}

output "connection_info" {
  value = {
    instance_id = aws_instance.this[0].id
    public_ip   = var.create_eip ? try(aws_eip.this[0].public_ip, null) : aws_instance.this[0].public_ip
    private_ip  = aws_instance.this[0].private_ip
  }
  description = "Informações de conexão da instância EC2"
}



# Root Volume
output "root_volume_id" {
  description = "ID of the root volume"
  value       = aws_instance.this[0].root_block_device[0].volume_id
}
