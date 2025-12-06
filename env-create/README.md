# Power Platform Environment Creation from CSV

This Terraform configuration creates Power Platform environments based on a CSV file.

## 📋 CSV File Format

The `environments.csv` file should have the following columns:

```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
```

### Column Definitions:

- **display_name**: Name of the environment (must be unique)
- **environment_type**: Type of environment
  - `Sandbox` - Development/testing
  - `Production` - Production environment
  - `Trial` - Trial environment
  - `Developer` - Developer environment
- **location**: Geographic location
  - `unitedstates`, `europe`, `asia`, `australia`, `india`, `japan`, `canada`, etc.
- **currency_code**: Currency code (e.g., `USD`, `EUR`, `GBP`)
- **language_code**: Language LCID code (e.g., `1033` for English)
- **security_group_id**: Azure AD Security Group Object ID (optional)
  - Leave empty for no security group restriction
  - Restricts environment access to members of the specified security group
  - Format: `12345678-1234-1234-1234-123456789abc`
- **enable_dataverse**: Boolean flag to enable Dataverse database (optional, defaults to `true`)
  - `true` - Creates environment with Dataverse database (allows apps, flows, and data storage)
  - `false` - Creates environment without Dataverse (canvas apps only, no database)
  - **When to use `false`:**
    - Simple canvas apps that don't need data storage
    - Environments for testing UI/UX only
    - Reduce costs by not provisioning database
  - **When to use `true`:**
    - Model-driven apps (requires Dataverse)
    - Apps that need data storage
    - Power Automate flows that use Dataverse
    - Most production scenarios
- **description**: Description of the environment (optional)

## 🚀 Usage

### Step 0: Get Security Group IDs (Optional)
Go to your Entra Admin to copy and existing or create a new group 

### Step 1: Update the CSV File

Edit `environments.csv` with your desired environments:

```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
Dev-Finance,Sandbox,unitedstates,USD,1033,12345678-1234-1234-1234-123456789abc,true,Development environment for Finance team
Dev-Sales,Sandbox,unitedstates,USD,1033,23456789-2345-2345-2345-23456789abcd,true,Development environment for Sales team
Test-UI,Sandbox,unitedstates,USD,1033,,false,UI testing without database
```

**Note**: Leave `security_group_id` empty if you don't want to restrict access, and use `false` for `enable_dataverse` if you don't need a database:
```csv
Dev-Public,Sandbox,unitedstates,USD,1033,,false,Public development environment - canvas apps only
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Plan the Deployment

```bash
terraform plan
```

### Step 4: Create the Environments

```bash
terraform apply
```

### Step 5: Review Outputs

After successful creation, you'll see:
- Environment IDs
- Environment URLs
- Environment names and types

## 📊 Example CSV Files

### Basic Setup (Standard Environments)
```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
Dev-Environment,Sandbox,unitedstates,USD,1033,,true,Main development environment
Test-Environment,Sandbox,unitedstates,USD,1033,,true,Testing environment
UI-Test,Sandbox,unitedstates,USD,1033,,false,UI testing only - no database
```

### Environments with Security Groups and Dataverse
```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
Prod-Finance,Production,unitedstates,USD,1033,12345678-1234-1234-1234-123456789abc,true,Finance team production
Prod-HR,Production,unitedstates,USD,1033,23456789-2345-2345-2345-23456789abcd,true,HR team production
Dev-Public,Sandbox,unitedstates,USD,1033,,false,Open dev environment - canvas only
```

### Multi-Region Setup
```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
US-Production,Production,unitedstates,USD,1033,12345678-1234-1234-1234-123456789abc,true,US Production environment
EU-Production,Production,europe,EUR,1031,12345678-1234-1234-1234-123456789abc,true,EU Production environment
UK-Production,Production,unitedkingdom,GBP,2057,12345678-1234-1234-1234-123456789abc,true,UK Production environment
```

### Department-Based Setup with Mixed Database Options
```csv
display_name,environment_type,location,currency_code,language_code,security_group_id,enable_dataverse,description
HR-Dev,Sandbox,unitedstates,USD,1033,aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa,true,HR Department Development
Finance-Dev,Sandbox,unitedstates,USD,1033,bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb,true,Finance Department Development
Sales-Dev,Sandbox,unitedstates,USD,1033,cccccccc-cccc-cccc-cccc-cccccccccccc,true,Sales Department Development
IT-Prod,Production,unitedstates,USD,1033,dddddddd-dddd-dddd-dddd-dddddddddddd,true,IT Production
Training-Canvas,Sandbox,unitedstates,USD,1033,eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee,false,Canvas app training - no database
```

## 🔧 Advanced Features

### Adding New Environments

Simply add a new row to the CSV file and run:
```bash
terraform apply
```

### Removing Environments

Remove the row from the CSV file and run:
```bash
terraform apply
```

**Note**: Environments have `prevent_destroy = false`, so they can be removed via Terraform.

### Modifying Environments

Most environment properties cannot be changed after creation. To modify:
1. Remove the environment from CSV
2. Run `terraform apply` to destroy it
3. Add it back with new values
4. Run `terraform apply` again

## 📝Language Codes
For a complete list of language codes, see: [Language Identifier Constants and Strings](https://learn.microsoft.com/en-us/openspecs/office_standards/ms-oe376/6c085406-a698-4e12-9d4d-c3b0ee3dbc4a)

## 🌍 Common Location Codes

- `unitedstates`
- `europe`
- `asia`
- `australia`
- `india`
- `japan`
- `canada`
- `unitedkingdom`
- `france`
- `germany`

## ⚠️ Important Notes

1. **Unique Names**: Each `display_name` must be unique
2. **Authentication**: Uses shared credentials from `../shared/terraform.tfvars`
3. **Dataverse**: All environments are created with Dataverse
4. **Permissions**: Ensure your service principal has permissions to create environments
5. **Security Groups**: 
   - Security group IDs must be valid Azure AD Object IDs
   - Users must be members of the security group to access the environment
   - Leave empty for no access restrictions
   - The service principal must have permissions to read security groups
6. **Access Control**: When a security group is specified:
   - Only members of that group can access the environment
   - Admins can still access via Power Platform Admin Center
   - Environment remains visible to all users, but access is restricted

## 🎯 Outputs

After running `terraform apply`, you'll get:

- `created_environments`: Complete details of all created environments including:
  - Environment ID
  - Display name
  - Environment type
  - Location
  - URL
  - Security group ID (if configured)
- `environment_count`: Total number of environments
- `environment_urls`: Map of environment names to URLs

### Example Output:
```
created_environments = {
  "Dev-Finance" = {
    display_name      = "Dev-Finance"
    environment_type  = "Sandbox"
    id                = "abc123..."
    location          = "unitedstates"
    security_group_id = "12345678-1234-1234-1234-123456789abc"
    url               = "https://orgxxx.crm.dynamics.com/"
  }
}
```