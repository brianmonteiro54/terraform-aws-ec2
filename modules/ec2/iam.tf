# =============================================================================
# IAM Role and Instance Profile
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for EC2 Instance
# -----------------------------------------------------------------------------
# =============================================================================
# IAM Role and Instance Profile
# =============================================================================

# ---------------------------------------------------------------------------
# IAM Role for EC2 Instance
# ---------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name        = "${local.instance_name}-role"
  description = "IAM role for EC2 instance ${local.instance_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Attach Managed Policies (replacing deprecated managed_policy_arns)
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "managed" {
  count = var.create_iam_instance_profile ? length(var.iam_role_managed_policy_arns) : 0

  role       = aws_iam_role.this[0].name
  policy_arn = var.iam_role_managed_policy_arns[count.index]
}

# ---------------------------------------------------------------------------
# IAM Instance Profile
# ---------------------------------------------------------------------------
resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${local.instance_name}-instance-profile"
  role = aws_iam_role.this[0].name

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# CloudWatch Logs Policy (if enabled)
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy" "cloudwatch_logs" {
  count = var.create_iam_instance_profile && var.enable_cloudwatch_logs ? 1 : 0

  name = "${local.instance_name}-cloudwatch-logs"
  role = aws_iam_role.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}",
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}:*"
        ]
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# SSM Policy (if enabled)
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_instance_profile && var.enable_ssm ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
