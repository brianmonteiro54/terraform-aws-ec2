# =============================================================================
# CloudWatch Alarms
# =============================================================================

# -----------------------------------------------------------------------------
# CPU Utilization Alarm
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.instance_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_cpu_utilization.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_cpu_utilization.period
  statistic           = "Average"
  threshold           = var.alarm_cpu_utilization.threshold
  alarm_description   = "Triggered when CPU exceeds ${var.alarm_cpu_utilization.threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
  InstanceId = aws_instance.this[0].id }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Status Check Failed Alarm
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.instance_name}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Triggered when instance status checks fail"
  treat_missing_data  = "notBreaching"

  dimensions = {
  InstanceId = aws_instance.this[0].id }

  alarm_actions = concat(var.alarm_actions, var.enable_auto_recovery ? ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"] : [])
  ok_actions    = var.ok_actions

  tags = local.common_tags
}
