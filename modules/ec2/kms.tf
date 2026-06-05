# =============================================================================
# KMS Key for EBS Encryption
# =============================================================================

# -----------------------------------------------------------------------------
# Customer-Managed KMS Key for EBS
# -----------------------------------------------------------------------------
resource "aws_kms_key" "ebs" {
  count = (var.kms_key_arn == null && var.enable_ebs_encryption && var.create_kms_key) ? 1 : 0

  description             = "KMS key for EC2 instance ${local.instance_name} EBS encryption"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.enable_multi_region

  policy = data.aws_iam_policy_document.kms.json

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-ebs-kms-key" }
  )
}


data "aws_iam_policy_document" "kms" {
  # checkov:skip=CKV_AWS_356: Root permissions required by AWS KMS key policy
  # checkov:skip=CKV_AWS_111: Root permissions required by AWS KMS key policy
  # checkov:skip=CKV_AWS_109: Root permissions required by AWS KMS key policy
  statement {
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
    resources = ["arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}


resource "aws_kms_alias" "ebs" {
  count = (var.kms_key_arn == null && var.enable_ebs_encryption && var.create_kms_key) ? 1 : 0

  name          = "alias/${local.instance_name}-ebs"
  target_key_id = aws_kms_key.ebs[0].key_id
}
