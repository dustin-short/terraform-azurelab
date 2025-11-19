# terraform-azurelab

## Azure Terraform Deployment — Bootstrap + Main Infrastructure

This project uses Terraform to deploy Azure resources using **remote state stored in Azure Storage**. The setup is split into two stages:

1. **Bootstrap** → Creates the Terraform state backend  
2. **Main Deployment** → Deploys actual Azure resources using that remote state

This README covers everything needed to initialize, authenticate, and run both stages.

---

### Requirements

- Linux Mint / Ubuntu
- Azure CLI
- Terraform ≥ 1.5
- `ARM_SUBSCRIPTION_ID` environment variable configured

---

### 1. Authenticate to Azure

Log in using the Azure CLI:

```bash
az login
```

If you have multiple subscriptions, select the correct one:

```bash
az account list --output table
az account set --subscription "<subscription-id-or-name>"
```

Verify:

```bash
az account show --output table
```

---

### 2. Set the Azure Subscription ID as an Environment Variable

Terraform uses environment variables for Azure authentication.

Set `ARM_SUBSCRIPTION_ID` in your `~/.bashrc` (NO sudo):

```bash
echo 'export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"' >> ~/.bashrc
source ~/.bashrc
```

Confirm:

```bash
echo $ARM_SUBSCRIPTION_ID
```

> **Important:** Do NOT use `sudo` when modifying your `.bashrc`. It will cause permission issues and break your environment variables.

---

### 3. Bootstrap Terraform Remote State

The bootstrap deployment sets up the Azure Storage backend used for Terraform state.

Navigate to the bootstrap directory:

```bash
cd ~/tf-azure-bootstrap
```

Initialize:

```bash
terraform init
```

Deploy:

```bash
terraform apply
```

This creates:

- A resource group for remote state (e.g., `rg-tfstate-dev`)
- A storage account with a randomized suffix
- A private `tfstate` blob container

Save the outputs — you will need them for the main deployment backend configuration.

---

### 4. Main Terraform Deployment (Using Remote State)

Navigate to your main Terraform project:

```bash
cd ~/tf-azure-main
```

Initialize Terraform, linking it to your backend storage account:

```bash
terraform init
```

Deploy your actual infrastructure:

```bash
terraform plan
terraform apply
```

This will:

- Connect Terraform to the remote backend in Azure
- Deploy your main resources (example: resource group + storage account)

---

### Project Structure

```
terraform-azurelab/
├── .gitignore
├── README.md
│
├── tf-azure-bootstrap/          # Remote state backend deployment
│   ├── main.tf                  # rg-tfstate-dev, storage account, container
│   ├── providers.tf
│   ├── outputs.tf
│   └── terraform.tfstate        # Remote or local (not committed)
│
└── tf-lab/                      # Your actual lab environment (Phase 1)
    ├── main.tf                  # Calls modules for RG, VNet, Subnets, VM later
    ├── providers.tf             # AzureRM provider + backend block
    ├── backend-lab.hcl          # Backend config (gitignored)
    │
    └── modules/
        ├── network/             # Network module (RG + VNet + Subnets)
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        │
        └── vm_cloudflare/ (future)
            ├── main.tf          # Cloudflare VM
            ├── variables.tf
            └── outputs.tf

```

---

### Cleanup

To destroy bootstrap resources:

```bash
cd tf-azure-bootstrap
terraform destroy
```

To destroy main deployment resources:

```bash
cd tf-lab

terraform destroy
```

---