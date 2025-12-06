# Power Platform Infrastructure as Code with Terraform

Terraform configurations for managing Power Platform environments, DLP policies, and infrastructure using Infrastructure as Code (IaC) principles.

## 📁 Repository Structure

```
powerplatform-iac-terraform/
├── shared/                    # Shared configuration and credentials
│   ├── terraform.tfvars       # Authentication credentials (DO NOT COMMIT)
│   ├── providers.tf           # Provider configuration
│   ├── variables.tf           # Variable definitions
│   └── outputs.tf            # Shared outputs
├── env-inventory/            # Export all environments to CSV
├── env-create/               # Create environments from CSV
├── dlp-inventory/            # Export all DLP policies to CSV
├── dlp-create/               # Create DLP policies from CSV
└── .github/                  # GitHub Actions workflows (optional)
```

## 🚀 Features

- **Environment Inventory**: Export all Power Platform environments to CSV
- **Environment Creation**: Bulk create environments from CSV file
- **DLP Policy Inventory**: Export all DLP policies with assignments to CSV
- **DLP Policy Creation**: Create DLP policies from CSV definitions
- **CSV-Based Management**: Easy bulk operations using CSV files
- **Shared Configuration**: Centralized authentication and provider setup

## 📋 Prerequisites

1. **Azure AD App Registration** with Power Platform Admin permissions
2. **Terraform** >= 1.6 installed
3. **GitHub Account** for version control
4. **Power Platform** tenant access

## 🔐 Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR-USERNAME/powerplatform-iac-terraform.git
cd powerplatform-iac-terraform
```

### Step 2: Configure Authentication

1. Copy the example credentials file:
```bash
cd shared
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `shared/terraform.tfvars` with your credentials:
```hcl
client_id     = "your-app-registration-client-id"
client_secret = "your-app-registration-client-secret"
tenant_id     = "your-azure-tenant-id"
```

**IMPORTANT**: Never commit `terraform.tfvars` with real credentials!

### Step 3: Initialize Terraform

Navigate to the desired module and initialize:

```bash
# For environment inventory
cd env-inventory
terraform init

# For environment creation
cd ../env-create
terraform init

# For DLP inventory
cd ../dlp-inventory
terraform init

# For DLP creation
cd ../dlp-create
terraform init
```

## 📚 Usage

### Environment Management

#### Export Environment Inventory
```bash
cd env-inventory
terraform apply
# Output: environment_inventory_<tenant-id>.csv
```

#### Create Environments from CSV
```bash
cd env-create
# Edit environments.csv with your environment definitions
terraform plan
terraform apply
```

### DLP Policy Management

#### Export DLP Policies
```bash
cd dlp-inventory
terraform apply
# Output: dlp_policies_<tenant-id>.csv
```

#### Create DLP Policies from CSV
```bash
cd dlp-create
# Edit dlp-policies.csv and dlp-connectors.csv
terraform plan
terraform apply
```

## 🔒 Security Best Practices

### What NOT to Commit

**NEVER commit these files to GitHub:**
- `shared/terraform.tfvars` (contains credentials)
- `*.tfstate` files (may contain sensitive data)
- `*.tfstate.backup` files
- `.terraform/` directories
- `*.csv` files with production data

### What TO Commit

**Safe to commit:**
- All `.tf` files (Terraform configuration)
- `terraform.tfvars.example` (template without credentials)
- Example CSV files with placeholder data
- Documentation (README files)
- `.gitignore` file

## 📦 Deploying to GitHub

### Initial Setup

1. **Create a new repository on GitHub:**
   - Go to https://github.com/new
   - Name: `powerplatform-iac-terraform`
   - Description: "Power Platform Infrastructure as Code with Terraform"
   - Visibility: Private (recommended) or Public
   - Do NOT initialize with README (we already have files)

2. **Initialize Git in your local directory:**
```bash
cd D:\Terraform\powerplatform-iac-terraform
git init
```

3. **Add .gitignore file** (already included in this repo)

4. **Stage and commit files:**
```bash
git add .
git commit -m "Initial commit: Power Platform IaC with Terraform"
```

5. **Add remote and push:**
```bash
git remote add origin https://github.com/YOUR-USERNAME/powerplatform-iac-terraform.git
git branch -M main
git push -u origin main
```

### Ongoing Development

```bash
# Make changes to files
git add .
git commit -m "Description of changes"
git push
```

## 🔄 CI/CD with GitHub Actions (Optional)

See `.github/workflows/` for example GitHub Actions workflows that can:
- Validate Terraform configurations on pull requests
- Run `terraform plan` automatically
- Deploy with `terraform apply` on approval

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📖 Documentation

Each module has its own README with detailed documentation:
- [Environment Inventory](./env-inventory/README.md)
- [Environment Creation](./env-create/README.md)
- [DLP Inventory](./dlp-inventory/README.md)
- [DLP Creation](./dlp-create/README.md)

## ⚠️ Important Notes

1. **State Management**: By default, Terraform state is stored locally. For team collaboration, consider using:
   - Azure Storage for remote state
   - Terraform Cloud
   - GitHub Actions with secure state storage

2. **Credentials Management**: 
   - Use environment variables or Azure Key Vault in production
   - Never commit credentials to version control
   - Use GitHub Secrets for CI/CD workflows

3. **Environment Isolation**: 
   - Use separate state files for dev/test/prod
   - Consider separate repositories or workspaces per environment

## 📝 License

MIT License - Feel free to use and modify for your needs.

## 🆘 Support

- [Power Platform Documentation](https://learn.microsoft.com/power-platform/)
- [Terraform Power Platform Provider](https://registry.terraform.io/providers/microsoft/power-platform/latest/docs)
- [Issues](https://github.com/YOUR-USERNAME/powerplatform-iac-terraform/issues)

## 🎯 Roadmap

- [ ] Add support for Power Platform environments with custom templates
- [ ] Add DLP policy templates for common scenarios
- [ ] Add support for solution deployments
- [ ] Add automated testing with Terratest
- [ ] Add Azure DevOps pipeline templates

---

**Made with ❤️ for Power Platform Admins**
