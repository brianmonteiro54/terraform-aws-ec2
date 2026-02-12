# =============================================================================
# Local Variables
# =============================================================================

locals {
  # Merge default tags with custom tags
  common_tags = merge(
    {
      Module      = "terraform-aws-ec2"
      ManagedBy   = "Terraform"
      Environment = var.environment
      CostCenter  = var.cost_center
    },
    var.tags
  )

  # Instance name with optional prefix
  instance_name = var.instance_name_prefix != "" ? "${var.instance_name_prefix}-${var.instance_name}" : var.instance_name

  # EBS Encryption logic
  enable_ebs_encryption = var.enable_ebs_encryption || var.kms_key_arn != null

  # KMS key ID to use
  kms_key_id = local.enable_ebs_encryption ? (
    var.kms_key_arn != null ? var.kms_key_arn : (
      var.create_kms_key ? aws_kms_key.ebs[0].arn : null
    )
  ) : null

  # Security Group IDs
  security_group_ids = concat(
    var.create_security_group ? [aws_security_group.this[0].id] : [],
    var.vpc_security_group_ids
  )

  # IAM Instance Profile
  instance_profile_name = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  # CloudWatch Log Group name
  cloudwatch_log_group_name = var.cloudwatch_log_group_name != null ? var.cloudwatch_log_group_name : "/aws/ec2/${local.instance_name}"
}
