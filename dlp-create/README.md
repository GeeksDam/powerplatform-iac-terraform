# Power Platform DLP Policy Creation from CSV

This Terraform configuration creates Data Loss Prevention (DLP) policies in Power Platform based on CSV file definitions.

## 📋 What This Does

- Creates DLP policies from `dlp-policies.csv`
- Assigns connectors to policies based on `dlp-connectors.csv`
- Classifies connectors as Business, NonBusiness, or Blocked
- Applies policies to specific environments or tenant-wide

## 📄 CSV File Format

### dlp-policies.csv

Defines the DLP policies and their scope.

```csv
policy_name,default_classification,environment_type,environments
Production-DLP-Policy,Confidential,OnlyEnvironments,env-id-1;env-id-2;env-id-3
Development-DLP-Policy,General,ExceptEnvironments,env-id-4
Tenant-Wide-Policy,General,AllEnvironments,
```

**Columns:**
- **policy_name**: Unique name for the DLP policy
- **default_classification**: Default classification for connectors not explicitly listed
  - `Confidential` - Stricter default
  - `General` - Less restrictive default
- **environment_type**: Scope of the policy
  - `AllEnvironments` - Apply to all environments in tenant
  - `OnlyEnvironments` - Apply only to specified environments
  - `ExceptEnvironments` - Apply to all except specified environments
- **environments**: Semicolon-separated list of environment IDs
  - Required for `OnlyEnvironments` and `ExceptEnvironments`
  - Leave empty for `AllEnvironments`

### dlp-connectors.csv

Defines which connectors are assigned to each policy and their classification.

```csv
policy_name,connector_id,classification
Production-DLP-Policy,/providers/Microsoft.PowerApps/apis/shared_sharepointonline,Business
Production-DLP-Policy,/providers/Microsoft.PowerApps/apis/shared_twitter,Blocked
Development-DLP-Policy,/providers/Microsoft.PowerApps/apis/shared_office365,NonBusiness
```

**Columns:**
- **policy_name**: Must match a policy name in `dlp-policies.csv`
- **connector_id**: Full connector ID (see Common Connectors section below)
- **classification**: Connector classification
  - `Business` - Business data group (can share data with other Business connectors)
  - `NonBusiness` - Non-business data group (can share data with other NonBusiness connectors)
  - `Blocked` - Completely blocked from use
- **connector_id**: Full connector ID (see Common Connectors section below)
- **classification**: Connector classification
  - `Business` - Business data group (can share data with other Business connectors)
  - `NonBusiness` - Non-business data group (can share data with other NonBusiness connectors)
  - `Blocked` - Completely blocked from use

## 🔌 Common Connector IDs

Here are some commonly used connector IDs:

### Microsoft 365 Connectors
- SharePoint: `/providers/Microsoft.PowerApps/apis/shared_sharepointonline`
- Office 365 Outlook: `/providers/Microsoft.PowerApps/apis/shared_office365`
- Office 365 Users: `/providers/Microsoft.PowerApps/apis/shared_office365users`
- OneDrive for Business: `/providers/Microsoft.PowerApps/apis/shared_onedriveforbusiness`
- Microsoft Teams: `/providers/Microsoft.PowerApps/apis/shared_teams`
- Planner: `/providers/Microsoft.PowerApps/apis/shared_planner`
- Microsoft Dataverse: `/providers/Microsoft.PowerApps/apis/shared_commondataservice`
- Azure AD: `/providers/Microsoft.PowerApps/apis/shared_azuread`

### Workflow & Automation
- Approvals: `/providers/Microsoft.PowerApps/apis/shared_approvals`
- Power Automate Management: `/providers/Microsoft.PowerApps/apis/shared_flowmanagement`

### Data & Databases
- SQL Server: `/providers/Microsoft.PowerApps/apis/shared_sql`
- Excel Online (Business): `/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness`

### Social Media (often blocked)
- Twitter: `/providers/Microsoft.PowerApps/apis/shared_twitter`
- Facebook: `/providers/Microsoft.PowerApps/apis/shared_facebook`
- LinkedIn: `/providers/Microsoft.PowerApps/apis/shared_linkedin`

### Cloud Storage
- Dropbox: `/providers/Microsoft.PowerApps/apis/shared_dropbox`
- Google Drive: `/providers/Microsoft.PowerApps/apis/shared_googledrive`
- Box: `/providers/Microsoft.PowerApps/apis/shared_box`

## 🚀 Usage

### Step 1: Get Environment IDs

First, get the IDs of environments where you want to apply policies:

```powershell
cd ../env-inventory
terraform apply
```

Copy the environment IDs from the output or CSV file.

### Step 2: Update CSV Files

Edit `dlp-policies.csv`:
```csv
policy_name,default_classification,environment_type,environments
My-Production-Policy,Confidential,OnlyEnvironments,abc-123-def;xyz-456-uvw
```

Edit `dlp-connectors.csv` to define connector classifications:
```csv
policy_name,connector_id,classification
My-Production-Policy,/providers/Microsoft.PowerApps/apis/shared_sharepointonline,Business
My-Production-Policy,/providers/Microsoft.PowerApps/apis/shared_twitter,Blocked
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan and Apply

```bash
terraform plan
terraform apply
```

## 📊 Example Scenarios

### Scenario 1: Strict Production Policy

Allows only Microsoft 365 connectors for business data:

**dlp-policies.csv:**
```csv
policy_name,default_classification,environment_type,environments
Strict-Production,Confidential,OnlyEnvironments,prod-env-id-1;prod-env-id-2
```

**dlp-connectors.csv:**
```csv
policy_name,connector_id,classification
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_sharepointonline,Business
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_office365,Business
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_teams,Business
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_commondataservice,Business
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_twitter,Blocked
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_facebook,Blocked
Strict-Production,/providers/Microsoft.PowerApps/apis/shared_dropbox,Blocked
```

### Scenario 2: Development Policy

More permissive for development environments:

**dlp-policies.csv:**
```csv
policy_name,default_classification,environment_type,environments
Relaxed-Development,General,OnlyEnvironments,dev-env-id-1;dev-env-id-2;dev-env-id-3
```

**dlp-connectors.csv:**
```csv
policy_name,connector_id,classification
Relaxed-Development,/providers/Microsoft.PowerApps/apis/shared_sharepointonline,Business
Relaxed-Development,/providers/Microsoft.PowerApps/apis/shared_commondataservice,Business
Relaxed-Development,/providers/Microsoft.PowerApps/apis/shared_office365,NonBusiness
Relaxed-Development,/providers/Microsoft.PowerApps/apis/shared_twitter,NonBusiness
```

### Scenario 3: Tenant-Wide Default Policy

Applies to all environments with basic restrictions:

**dlp-policies.csv:**
```csv
policy_name,default_classification,environment_type,environments
Tenant-Default,General,AllEnvironments,
```

**dlp-connectors.csv:**
```csv
policy_name,connector_id,classification
Tenant-Default,/providers/Microsoft.PowerApps/apis/shared_sharepointonline,Business
Tenant-Default,/providers/Microsoft.PowerApps/apis/shared_office365,Business
Tenant-Default,/providers/Microsoft.PowerApps/apis/shared_commondataservice,Business
Tenant-Default,/providers/Microsoft.PowerApps/apis/shared_twitter,Blocked
Tenant-Default,/providers/Microsoft.PowerApps/apis/shared_facebook,Blocked
```

## 🔍 Understanding DLP Classifications

### Business Data Group
- Connectors in this group can share data with each other
- Typically includes Microsoft 365 and internal business systems
- Example: SharePoint + Dataverse can share data

### Non-Business Data Group
- Connectors in this group can share data with each other
- Cannot share data with Business data group connectors
- Typically includes external services for personal use

### Blocked Connectors
- Completely blocked from use in apps and flows
- Users cannot add these connectors to their solutions
- Typically includes social media or unauthorized cloud storage

## 📝 Important Notes

1. **Policy Conflicts**: If multiple policies apply to an environment, the most restrictive wins
2. **Default Classification**: Connectors not explicitly listed use the default classification
3. **Environment IDs**: Use actual environment GUIDs from your tenant
4. **Authentication**: Uses shared credentials from `../shared/terraform.tfvars`
5. **Permissions**: Service principal needs Power Platform Administrator or Global Administrator role

## 🔧 Troubleshooting

### Finding Connector IDs

To find connector IDs, you can:
1. Use Power Platform Admin Center
2. Use PowerShell: `Get-PowerAppManagementApp`
3. Check Microsoft documentation: [Connector Reference](https://learn.microsoft.com/en-us/connectors/)

### Policy Not Applying

- Verify environment IDs are correct
- Check service principal has admin permissions
- Ensure no conflicting policies exist
- Review Terraform output for errors

### Modifying Existing Policies

To update a policy:
1. Edit the CSV files
2. Run `terraform plan` to see changes
3. Run `terraform apply` to update

To remove a policy:
1. Remove from CSV files
2. Run `terraform apply`

## 🔄 Outputs

After applying, Terraform will output:

- **dlp_policy_count**: Number of policies created
- **created_dlp_policies**: Details of each policy including:
  - Policy ID
  - Display name
  - Environment type
  - Connector counts by classification

## 📚 Additional Resources

- [Power Platform DLP Documentation](https://learn.microsoft.com/en-us/power-platform/admin/wp-data-loss-prevention)
- [Connector Reference](https://learn.microsoft.com/en-us/connectors/)
- [DLP Best Practices](https://learn.microsoft.com/en-us/power-platform/guidance/adoption/dlp-strategy)
