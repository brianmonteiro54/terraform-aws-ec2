# 🖥️ Terraform AWS EC2

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~%3E%206.31-FF9900?logo=amazonaws)](https://registry.terraform.io/providers/hashicorp/aws/latest)

> **FIAP — Pós Tech · Tech Challenge — Fase 03 · ToggleMaster**
>
> Módulo Terraform para provisionamento de instâncias **Amazon EC2** com Security Groups, IAM, EBS encryption, Elastic IP e monitoramento.

---

## 📋 Descrição

Módulo production-ready para instâncias EC2 com:

- **AMI dinâmica** — auto-seleciona Amazon Linux 2023 ou AMI customizada
- **IMDSv2 obrigatório** (security best practice)
- **EBS Encryption** com KMS (gerenciada AWS ou CMK)
- **Elastic IP** com associação automática (opcional)
- **Security Groups** configuráveis via variáveis
- **IAM Instance Profile** com policies gerenciadas
- **SSM Agent** para acesso sem SSH (opcional)
- **CloudWatch Logs** para centralização de logs
- **CloudWatch Alarms** para CPU e status checks
- **Auto Recovery** em caso de falha de hardware
- **User Data** para bootstrapping customizado

---

## 📦 Recursos Criados

| Recurso | Descrição |
|---------|-----------|
| `aws_instance` | Instância EC2 |
| `aws_eip` / `aws_eip_association` | Elastic IP (opcional) |
| `aws_security_group` | Security group com regras dinâmicas |
| `aws_iam_role` / `aws_iam_instance_profile` | IAM role e profile (opcional) |
| `aws_kms_key` / `aws_kms_alias` | KMS para EBS encryption (opcional) |
| `aws_cloudwatch_metric_alarm` | Alarmes CPU e status check |

---

## 🚀 Uso no ToggleMaster

Utilizado para o servidor **Pritunl VPN**, permitindo acesso seguro ao cluster EKS (endpoint privado):

```hcl
module "pritunl_vpn" {
  source = "github.com/brianmonteiro54/terraform-aws-ec2//modules/ec2?ref=<commit-sha>"

  instance_name = "Pritunl_VPN_prod"
  environment   = "production"

  ami_id               = "ami-096ea6a12ea24a797"
  instance_type        = "t4g.micro"
  iam_instance_profile = "LabInstanceProfile"
  user_data            = file("ec2_userdata.sh")

  vpc_id                      = module.vpc.vpc_id
  subnet_id                   = module.vpc.public_subnet_ids[0]
  associate_public_ip_address = true
  create_eip                  = true

  root_volume_size      = 8
  root_volume_type      = "gp3"
  enable_ebs_encryption = true
  create_kms_key        = false

  create_security_group = true
  security_group_ingress_rules = [
    { from_port = 80,   to_port = 80,   protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 443,  to_port = 443,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 5050, to_port = 5050, protocol = "udp", cidr_blocks = ["0.0.0.0/0"] },
  ]

  enable_cloudwatch_alarms = true
  enable_auto_recovery     = true
}
```

---

## 📁 Estrutura

```
terraform-aws-ec2/
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── eip.tf
│       ├── security_groups.tf
│       ├── iam.tf
│       ├── kms.tf
│       ├── alarms.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── locals.tf
│       ├── data.tf
│       └── versions.tf
├── .github/workflows/
│   └── terraform-ci.yml
└── LICENSE
```
## 📄 Licença

[MIT License](LICENSE)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->