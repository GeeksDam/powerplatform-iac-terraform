# Power Platform DLP Policy Inventory

This Terraform configuration retrieves all Data Loss Prevention (DLP) policies from your Power Platform tenant and exports them to a CSV file.

## 📋 What This Does

- Retrieves all DLP policies in your tenant
- Lists assigned environments for each policy
- Exports data to CSV file: `dlp_policies_<tenant_id>.csv`
- Provides summary output of all policies

## 📊 CSV File Format

The generated CSV file contains the following columns:

- **policy_display_name**: Name of the DLP policy
- **policy_id**: Unique identifier for the policy
- **default_connectors_classification**: Default classification for connectors (Business, NonBusiness, Blocked)
- **environment_type**: Type of environments the policy applies to (AllEnvironments, OnlyEnvironments, ExceptEnvironments)
- **environments**: Semicolon-separated list of environment IDs assigned to the policy

## 🚀 Usage

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Run the Inventory

```bash
terraform apply
```

### Step 3: View the Results

The CSV file will be created in the current directory as `dlp_policies_<tenant_id>.csv`

You can also view the summary in the terminal output.

## 📄 Output Example

### Console Output
```
Outputs:

csv_file_location = "./dlp_policies_12345678-1234-1234-1234-123456789abc.csv"
dlp_policy_count = 3
dlp_policies_summary = {
  "Tenant-wide Default Policy" = {
    default_classification = "General"
    environment_count = 0
    environment_type = "AllEnvironments"
    id = "abc-123-def"
  }
  "Production Environments Policy" = {
    default_classification = "Confidential"
    environment_count = 5
    environment_type = "OnlyEnvironments"
    id = "xyz-456-uvw"
  }
}
```

### CSV File Example
```csv
policy_display_name,policy_id,default_connectors_classification,environment_type,environments
Tenant-wide Default Policy,abc-123-def,General,AllEnvironments,""
Production Environments Policy,xyz-456-uvw,Confidential,OnlyEnvironments,"env-id-1;env-id-2;env-id-3"
Development Policy,rst-789-opq,General,ExceptEnvironments,"env-id-4;env-id-5"
```

## 🔍 Understanding the Data

### Environment Type Values
- **AllEnvironments**: Policy applies to all environments in the tenant
- **OnlyEnvironments**: Policy applies only to specified environments
- **ExceptEnvironments**: Policy applies to all environments except specified ones

### Default Connectors Classification
- **General**: Connectors not explicitly classified use this default
- **Business**: Connectors allowed for business use
- **NonBusiness**: Connectors for non-business use
- **Blocked**: Connectors that are blocked

## 📝 Notes

1. **Authentication**: Uses shared credentials from `../shared/terraform.tfvars`
2. **Permissions**: Service principal needs read access to DLP policies
3. **File Overwrite**: Running `terraform apply` again will overwrite the existing CSV file
4. **No State Changes**: This is read-only; no resources are created in Power Platform

## 🔧 Troubleshooting

### Permission Issues
If you encounter permission errors, ensure your service principal has:
- Power Platform Administrator role, or
- Dynamics 365 Administrator role, or
- Global Administrator role

### Empty Results
If no policies are returned:
- Verify authentication credentials in `../shared/terraform.tfvars`
- Check that DLP policies exist in your tenant
- Confirm service principal has necessary permissions

## 🔄 Refreshing the Inventory

To update the inventory with the latest data:

```bash
terraform apply -refresh-only
terraform apply
```

This will fetch the latest DLP policy data and regenerate the CSV file.
