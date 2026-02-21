# Complete TFE Workspace Example

This example demonstrates comprehensive usage of the `terraform-tfe-workspace` module with various configurations:

1. **Basic workspace** - Minimal VCS integration
2. **Custom workspace** - Advanced settings and configuration
3. **Production workspace** - OIDC dynamic credentials with production settings
4. **Staging workspace** - OIDC dynamic credentials with staging settings
5. **Advanced workspace** - Custom trigger patterns and variables
6. **Development workspace** - Manual apply with development settings

## Architecture

The example creates a complete workspace hierarchy for a typical application:

```
┌─────────────────────────────────────────────────────────────┐
│                    Terraform Cloud Organization             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Development │  │   Staging   │  │ Production  │        │
│  │  (manual)   │  │  (OIDC)     │  │   (OIDC)    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    Basic    │  │   Custom    │  │  Advanced   │        │
│  │   (VCS)     │  │  (settings) │  │ (triggers)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## Usage

1. **Set up Terraform Cloud credentials**:
   ```bash
   export TFE_TOKEN="your-terraform-cloud-token"
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Configuration Details

### Basic Workspace (`basic_workspace`)
- Minimal VCS integration
- Default settings (remote execution, auto-apply=false)
- No OIDC credentials

### Custom Workspace (`custom_workspace`)
- Custom branch (`develop`)
- Local execution mode
- Disabled speculative plans
- Custom working directory
- Specific tags

### Production Workspace (`production_workspace`)
- OIDC dynamic credentials with AWS IAM role
- Production environment variables
- Sensitive database credentials
- Critical tags
- Auto-apply enabled

### Staging Workspace (`staging_workspace`)
- OIDC dynamic credentials with different IAM role
- Staging environment variables
- Smaller instance types
- Testing tags

### Advanced Workspace (`advanced_workspace`)
- Explicit trigger patterns
- Custom working directory
- Branch-specific configuration
- Project variables

### Development Workspace (`development_workspace`)
- Manual apply only
- Development environment variables
- Debug mode enabled
- Experimental tags

## OIDC Configuration

Workspaces with `role_arn` set will automatically create:
1. **Variable set** for OIDC credentials
2. **Workspace variable set attachment**
3. **OIDC authentication variables**:
   - `TFC_AWS_PROVIDER_AUTH = "true"`
   - `TFC_AWS_RUN_ROLE_ARN = <role_arn>`

## Workspace Variables

The module supports two types of variables:

### Environment Variables (`category = "env"`)
- Available to Terraform runs as environment variables
- Can be marked as sensitive
- Examples: `TF_VAR_environment`, `TF_VAR_database_url`

### Terraform Variables (`category = "terraform"`)
- Set as Terraform input variables
- Non-sensitive configuration
- Examples: `aws_region`, `instance_type`

## Trigger Patterns

By default, trigger patterns are auto-derived from the `working_directory`:
- `working_directory = "infra"` → `["infra/**/*.tf", "infra/**/*.tfvars"]`

You can override with explicit patterns:
```hcl
trigger_patterns = ["infrastructure/**/*.tf", "infrastructure/**/*.tfvars", "infrastructure/**/*.json"]
```

## Outputs

After applying, you'll get:
- **Workspace IDs** for each created workspace
- **OIDC variable set IDs** (when applicable)
- **Workspace URLs** for easy access in Terraform Cloud

## Customization

1. **Update organization and repository names** to match your setup
2. **Adjust IAM role ARNs** for OIDC credentials
3. **Modify workspace variables** for your specific environment needs
4. **Change execution mode** (remote/local) based on your requirements
5. **Add custom tags** for organization and filtering

## Security Notes

- Use separate IAM roles for different environments (production, staging)
- Mark sensitive variables (passwords, tokens) as `sensitive = true`
- Consider using `auto_apply = false` for production workspaces
- Regularly review and update workspace permissions
- Use `force_delete = false` for critical workspaces to prevent accidental deletion