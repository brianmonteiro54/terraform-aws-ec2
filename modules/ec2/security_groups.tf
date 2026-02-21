# =============================================================================
# Security Group
# =============================================================================

# -----------------------------------------------------------------------------
# Security Group for EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_security_group" "this" {
  # checkov:skip=CKV2_AWS_5: Security group is attached to EC2 instance in this module
  count = var.create_security_group ? 1 : 0

  name_prefix = "${local.instance_name}-"
  description = "Security group for EC2 instance ${local.instance_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.instance_name}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Security Group Rules - Ingress
# -----------------------------------------------------------------------------
resource "aws_security_group_rule" "ingress" {
  # checkov:skip=CKV2_AWS_5:Security group is attached to EC2 instance in this module
  for_each = var.create_security_group ? { for idx, rule in var.security_group_ingress_rules : idx => rule } : {}

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  security_group_id        = aws_security_group.this[0].id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description              = lookup(each.value, "description", "Managed by Terraform")
}

# -----------------------------------------------------------------------------
# Security Group Rules - Egress
# -----------------------------------------------------------------------------
resource "aws_security_group_rule" "egress" {
  for_each = var.create_security_group ? { for idx, rule in var.security_group_egress_rules : idx => rule } : {}

  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  security_group_id        = aws_security_group.this[0].id
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  description              = lookup(each.value, "description", "Managed by Terraform")
}
