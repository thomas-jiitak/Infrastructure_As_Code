# Infrastructure Automation with Packer, Ansible, Terraform, and GitHub Actions

## Overview

This project demonstrates a complete CI/CD pipeline to provision EC2 infrastructure on AWS using:

- **Packer** to create a custom AMI.
- **Ansible** for provisioning and configuration during AMI creation.
- **Terraform** to deploy infrastructure using the built AMI.
- **GitHub Actions** for automating the entire workflow.

---

## 📦 Project Structure
```
Infrastructure_As_Code/
├── .github/
│   └── workflows/
│       ├── packer_build.yml         # Packer + Ansible CI pipeline
│       └── terraform_build.yml      # Terraform deployment pipeline
├── packer/
│   ├── aws-docker-ubuntu.pkr.hcl    # Packer configuration
│   ├── scripts/
│   │   ├── update.sh                # Common OS update script
│   │   └── cleanup.sh              # Cleanup after provisioning
├── ansible/
│   └── playbook.yml                 # Ansible playbook for AMI provisioning
├── terraform/
│   ├── main.tf                      # Terraform main config
│   ├── EC2/                         # EC2 module using AMI
│   ├── SG/                          # Security Group module
│   ├── variables.tf                 # Terraform variables
│   └── outputs.tf                   # Terraform outputs
└── README.md
```

## ⚙️ CI/CD Pipeline Overview

### 1. Packer Build Workflow

File: `.github/workflows/packer_build.yml`

- Runs on every push to `main`.
- Uses Packer to build an AMI from a base Ubuntu image.
- Provisions the instance using Ansible.
- Stores the resulting AMI ID in a manifest file.
- **Triggers** the Terraform workflow by passing the new AMI ID.

### 2. Terraform Deploy Workflow

File: `.github/workflows/terraform_build.yml`

- Triggered via `workflow_dispatch` from the Packer pipeline.
- Receives the AMI ID as input.
- Initializes and applies Terraform to:
  - Create a VPC
  - Create Security Groups
  - Launch EC2 instance using the new AMI

---

## 🔐 Secrets Required (in GitHub Actions)

Make sure these are configured in your repo settings under `Settings > Secrets and variables > Actions`:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `GH_PAT` (for triggering downstream workflows using `workflow-dispatch`)

---

## ✅ Usage

### Build and Deploy Flow

1. Push changes to `main`:
   ```bash
   git push origin main

	2.	GitHub Actions will:
	•	Build AMI using Packer + Ansible
	•	Trigger Terraform pipeline with the new AMI ID
	•	Deploy EC2 instance using Terraform

⸻

📌 Notes

	•	Terraform version used: 1.5.x recommended for modern syntax (e.g., optional attributes).
	•	Packer uses an Ansible local provisioner to install and configure packages on the AMI.
	•	Terraform modules are organized and reusable (e.g., EC2, SG, VPC, keypair).

⸻

📷 Outputs

	•	✅ AMI created: Visible in AWS Console under EC2 > AMIs
	•	✅ EC2 launched: View in AWS EC2 Dashboard
	•	✅ CI/CD logs: Available in GitHub Actions tab

⸻

🚀 Future Improvements

	•	Add support for multiple environments (e.g., staging, production)
	•	Integrate Slack/Teams notifications
	•	Enable S3 remote backend for Terraform state
	•	Auto-deregister old AMIs and delete unused snapshots

⸻

🛠️ Requirements

	•	AWS Account
	•	GitHub Repository
	•	GitHub Actions enabled
	•	Terraform CLI (>=1.5.0 recommended)
	•	Packer (>=1.8.0)
	•	Ansible (>=2.10)

⸻