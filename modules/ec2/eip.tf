# =============================================================================
# Elastic IP Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Elastic IP
# -----------------------------------------------------------------------------
resource "aws_eip" "this" {
  count = var.create_eip ? 1 : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.instance_name}-eip"
    }
  )

}

# -----------------------------------------------------------------------------
# EIP Association
# -----------------------------------------------------------------------------
resource "aws_eip_association" "this" {
  count = var.create_eip ? 1 : 0

  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this[0].id

  depends_on = [aws_instance.this]
}
