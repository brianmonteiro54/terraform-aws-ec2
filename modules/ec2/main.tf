# =============================================================================
# AWS EC2 Instance Module - Production Ready with Security Best Practices
# =============================================================================
# This file contains ONLY the main EC2 instance resource

# -----------------------------------------------------------------------------
# EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_instance" "this" {
  ami           = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Networking
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip

  # IAM
  iam_instance_profile = local.instance_profile_name

  # Storage - Root Block Device
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_type == "io1" || var.root_volume_type == "io2" ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
    encrypted             = local.enable_ebs_encryption
    kms_key_id            = local.kms_key_id
    delete_on_termination = var.root_volume_delete_on_termination
  }

  # Additional EBS Volumes
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = ebs_block_device.value.volume_size
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = local.enable_ebs_encryption
      kms_key_id            = local.kms_key_id
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)

      tags = merge(
        local.common_tags,
        {
          Name = "${local.instance_name}-${ebs_block_device.value.device_name}"
        }
      )
    }
  }

  # Instance Settings
  ebs_optimized = var.ebs_optimized
  monitoring    = var.enable_detailed_monitoring

  # User Data
  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  # Metadata Options - IMDSv2 (Security Best Practice)
  metadata_options {
    http_endpoint               = var.metadata_options_http_endpoint
    http_tokens                 = var.metadata_options_http_tokens # "required" for IMDSv2
    http_put_response_hop_limit = var.metadata_options_http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options_instance_metadata_tags
  }

  # Credit Specification (for T2/T3 instances)
  dynamic "credit_specification" {
    for_each = var.credit_specification != null ? [var.credit_specification] : []
    content {
      cpu_credits = credit_specification.value
    }
  }

  # Source/Dest Check (disable for NAT instances)
  source_dest_check = var.source_dest_check

  # Termination Protection
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  # Tags
  tags = merge(
    local.common_tags,
    {
      Name = local.instance_name
    }
  )

  volume_tags = merge(
    local.common_tags,
    {
      Name = "${local.instance_name}-volume"
    }
  )

  # Lifecycle
  lifecycle {
    ignore_changes = [ami]
  }

  # Dependencies
  depends_on = [
    aws_iam_role.this,
    aws_iam_instance_profile.this
  ]
}
