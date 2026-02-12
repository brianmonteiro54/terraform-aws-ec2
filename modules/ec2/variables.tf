# =============================================================================
# Variables - EC2 Module
# =============================================================================

# Required Variables
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  validation {
    condition     = can(regex("^(dev|development|staging|stage|prod|production|qa|test)$", var.environment))
    error_message = "Environment must be valid."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

# Optional - Instance Configuration
variable "instance_name_prefix" {
  description = "Prefix for instance name"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID (if null, uses latest Amazon Linux 2023)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

# Storage
variable "root_volume_type" {
  description = "Root volume type (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "root_volume_iops" {
  description = "Root volume IOPS (for io1/io2)"
  type        = number
  default     = null
}

variable "root_volume_throughput" {
  description = "Root volume throughput (for gp3)"
  type        = number
  default     = null
}

variable "root_volume_delete_on_termination" {
  description = "Delete root volume on termination"
  type        = bool
  default     = true
}

variable "ebs_block_devices" {
  description = "Additional EBS volumes"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    snapshot_id           = optional(string)
    delete_on_termination = optional(bool)
  }))
  default = []
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

# Security - Encryption
variable "enable_ebs_encryption" {
  description = "Enable EBS encryption"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Create custom KMS key for EBS encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of existing KMS key"
  type        = string
  default     = null
}

variable "kms_deletion_window_in_days" {
  description = "KMS key deletion window"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "Must be between 7 and 30 days."
  }
}

variable "enable_multi_region" {
  description = "Enable multi-region KMS key"
  type        = bool
  default     = false
}

# Networking
variable "associate_public_ip_address" {
  description = "Associate public IP"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID (required if creating security group)"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Create security group"
  type        = bool
  default     = false
}

variable "security_group_ingress_rules" {
  description = "Ingress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    description              = optional(string)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "Egress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks         = optional(list(string))
    prefix_list_ids          = optional(list(string))
    source_security_group_id = optional(string)
    description              = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
}

# IAM
variable "create_iam_instance_profile" {
  description = "Create IAM instance profile"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "Managed policy ARNs to attach to role"
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Enable AWS Systems Manager"
  type        = bool
  default     = false
}

# Elastic IP
variable "create_eip" {
  description = "Create and associate Elastic IP"
  type        = bool
  default     = false
}
# Monitoring
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = null
}

variable "alarm_cpu_utilization" {
  description = "CPU alarm configuration"
  type = object({
    threshold          = number
    evaluation_periods = number
    period             = number
  })
  default = {
    threshold          = 80
    evaluation_periods = 2
    period             = 300
  }
}

variable "alarm_actions" {
  description = "SNS topic ARNs for alarm actions"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "SNS topic ARNs for OK actions"
  type        = list(string)
  default     = []
}

variable "enable_auto_recovery" {
  description = "Enable auto recovery on status check failure"
  type        = bool
  default     = false
}

# User Data
variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "User data script (base64 encoded)"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Replace instance when user data changes"
  type        = bool
  default     = false
}

# Metadata Options (IMDSv2)
variable "metadata_options_http_endpoint" {
  description = "Enable/disable metadata service"
  type        = string
  default     = "enabled"
}

variable "metadata_options_http_tokens" {
  description = "Require IMDSv2"
  type        = string
  default     = "required"
}

variable "metadata_options_http_put_response_hop_limit" {
  description = "Hop limit for metadata requests"
  type        = number
  default     = 1
}

variable "metadata_options_instance_metadata_tags" {
  description = "Enable instance tags in metadata"
  type        = string
  default     = "enabled"
}

# Instance Settings
variable "credit_specification" {
  description = "Credit specification for T2/T3 instances"
  type        = string
  default     = null
}

variable "source_dest_check" {
  description = "Enable source/destination check"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Termination protection"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior"
  type        = string
  default     = "stop"
}

# Tags
variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Cost center"
  type        = string
  default     = "engineering"
}
