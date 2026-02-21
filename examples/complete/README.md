# Example: Complete EC2 Instance

This example provisions a production-ready EC2 instance following AWS security best practices.

## What is created

- EC2 instance with Amazon Linux 2023 (latest AMI auto-selected)
- EBS root volume encrypted with a customer-managed KMS key
- Security group with no inbound rules (SSM-only access)
- IAM role with `AmazonSSMManagedInstanceCore` policy attached
- IMDSv2 enforced (no IMDSv1)
- Detailed CloudWatch monitoring enabled

## Usage

```bash
terraform init

terraform plan \
  -var="subnet_id=subnet-xxxxxxxxxxxxxxxxx" \
  -var="vpc_id=vpc-xxxxxxxxxxxxxxxxx"

terraform apply \
  -var="subnet_id=subnet-xxxxxxxxxxxxxxxxx" \
  -var="vpc_id=vpc-xxxxxxxxxxxxxxxxx"
```

## Connecting to the instance

Since there are no inbound rules and no key pair, use SSM Session Manager:

```bash
aws ssm start-session --target <instance_id>
```

## Inputs

| Name | Description | Required |
|------|-------------|----------|
| subnet_id | Subnet ID for the instance | Yes |
| vpc_id | VPC ID for the security group | Yes |
| aws_region | AWS region | No (default: `us-east-1`) |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | EC2 instance ID |
| instance_private_ip | Private IP address |
| iam_role_arn | IAM role ARN |
| kms_key_arn | KMS key ARN used for EBS encryption |
| security_group_id | Security group ID |

> **Note:** This example uses `create_kms_key = true`. In production, consider
> reusing a shared KMS key via `kms_key_arn` to reduce costs.
