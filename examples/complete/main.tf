# =============================================================================
# Example: Complete EC2 Instance
#
# This example deploys a production-ready EC2 instance with:
#   - Latest Amazon Linux 2023 AMI (auto-selected)
#   - IMDSv2 enforced (security best practice)
#   - EBS encryption with a customer-managed KMS key
#   - IAM role + SSM access (no SSH required)
#   - Security group allowing only HTTPS outbound
#   - CloudWatch detailed monitoring enabled
#
# Usage:
#   terraform init
#   terraform plan -var="subnet_id=subnet-xxxx" -var="vpc_id=vpc-xxxx"
#   terraform apply -var="subnet_id=subnet-xxxx" -var="vpc_id=vpc-xxxx"
# =============================================================================

module "ec2" {
  source = "../../modules/ec2"

  # ---------------------------------------------------
  # Required
  # ---------------------------------------------------
  instance_name = "web-server"
  environment   = "dev"
  subnet_id     = var.subnet_id

  # ---------------------------------------------------
  # Instance
  # ---------------------------------------------------
  instance_type = "t3.micro"
  # ami_id = null  # null = auto uses latest Amazon Linux 2023

  # ---------------------------------------------------
  # Storage
  # ---------------------------------------------------
  root_volume_type = "gp3"
  root_volume_size = 20
  enable_ebs_encryption = true
  create_kms_key        = true

  # ---------------------------------------------------
  # Networking
  # No public IP — access via SSM
  # ---------------------------------------------------
  associate_public_ip_address = false
  vpc_id                      = var.vpc_id
  create_security_group       = true

  security_group_ingress_rules = []  # No inbound — SSM only

  security_group_egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS outbound for SSM and package updates"
    }
  ]

  # ---------------------------------------------------
  # IAM + SSM (replaces SSH access)
  # ---------------------------------------------------
  create_iam_instance_profile = true
  enable_ssm                  = true

  # ---------------------------------------------------
  # Monitoring
  # ---------------------------------------------------
  enable_detailed_monitoring = true
  enable_cloudwatch_alarms   = false  # Set true and provide alarm_actions for SNS

  # ---------------------------------------------------
  # Security - IMDSv2 enforced (default)
  # ---------------------------------------------------
  metadata_options_http_tokens                 = "required"
  metadata_options_http_put_response_hop_limit = 1

  # ---------------------------------------------------
  # Tags
  # ---------------------------------------------------
  tags = {
    Project    = "my-app"
    Owner      = "platform-team"
    CostCenter = "engineering"
  }
}
