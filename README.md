# Terraform OCI Compute Stack

This Terraform project provisions a complete infrastructure on Oracle Cloud Infrastructure (OCI) with CPU and GPU compute instances, including network configuration, security, and automated tools.

## Overview

The stack creates:
- **VCN Network** with public and private subnets
- **Flexible Compute Instances** (CPU and GPU)
- **Automated configuration** with Docker and NVIDIA Docker
- **Automatically generated SSH keys**
- **Auxiliary tools** for management

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          VCN                                │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │   Public Subnet     │    │     Private Subnet          │ │
│  │   10.0.1.0/24       │    │     10.0.2.0/24             │ │
│  │                     │    │                             │ │
│  │  ┌───────────────┐  │    │  ┌───────────────────────┐  │ │
│  │  │  CPU Node     │  │    │  │  CPU Node Private     │  │ │
│  │  │  VM.E5.Flex   │  │    │  │  VM.E5.Flex           │  │ │
│  │  │  (Public IP)  │  │    │  │  (Private IP only)    │  │ │
│  │  └───────────────┘  │    │  └───────────────────────┘  │ │
│  │                     │    │                             │ │
│  │  ┌───────────────┐  │    │                             │ │
│  │  │  GPU Node     │  │    │                             │ │
│  │  │  VM.GPU.A10.1 │  │    │                             │ │
│  │  │  (Public IP)  │  │    │                             │ │
│  │  └───────────────┘  │    │                             │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Features

### Pre-configured Instances

#### CPU Node Public (VM.Standard.E5.Flex)
- **vCPUs**: 1
- **Memory**: 8 GB
- **Boot Volume**: 50 GB
- **Network**: Public subnet with public IP
- **Docker**: ✅ Installed
- **NVIDIA Docker**: ❌
- **OCI Growfs**: ✅ Enabled
- **Local Storage**: ❌ Not available
- **OS**: Oracle Linux

#### CPU Node Private (VM.Standard.E5.Flex)
- **vCPUs**: 1
- **Memory**: 8 GB
- **Boot Volume**: 50 GB
- **Network**: Private subnet (no public IP)
- **Docker**: ❌ Not installed
- **NVIDIA Docker**: ❌
- **OCI Growfs**: ✅ Enabled
- **Local Storage**: ❌ Not available
- **OS**: Oracle Linux

#### GPU Node (VM.GPU.A10.1)
- **GPU**: NVIDIA A10
- **Boot Volume**: 150 GB
- **Network**: Public subnet with public IP
- **Docker**: ✅ Installed
- **NVIDIA Docker**: ✅ Installed
- **OCI Growfs**: ✅ Enabled
- **Local Storage**: ❌ Not available
- **OS**: Oracle Linux

### Automatic Features
- **Automatic SSH key generation**
- **Docker installation** (public instances)
- **NVIDIA Docker configuration** (GPU instances)
- **OCI Growfs** for automatic disk expansion
- **Local Storage setup** (when enabled)

### Network Configuration
- **Public Instances**: Direct internet access with public IP
- **Private Instances**: Internal network only, no public IP

### Local Storage Configuration
- **NVMe Local Storage**: High-performance local storage for instances that support it
- **Automatic Setup**: When enabled, configures and mounts local NVMe drives
- **Performance**: Provides faster I/O for applications requiring high-performance storage
- **Temporary Storage**: Local storage is ephemeral and lost when instance is terminated

## Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- Oracle Cloud Infrastructure access

### OCI Configuration
```bash
# Configure OCI CLI
oci setup config

# Verify configuration
oci iam user get --user-id <your-user-ocid>
```

## Configuration

### 1. Clone the Repository
```bash
git clone <repository-url>
cd terraform-oci-compute-stack
```

### 2. Configure Variables
Edit the `terraform.tfvars` file:

```hcl
# REQUIRED: Compartment OCID
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa..."

# OCI CLI profile (optional, default: DEFAULT)
profile = "DEFAULT"

# Region (optional, default: sa-saopaulo-1)
region = "sa-saopaulo-1"
```

### 3. Customize Instances (Optional)
Modify configurations in `variables.tf`:

```hcl
shapes = {
  "cpu-node-public" = {
    shape                   = "VM.Standard.E5.Flex"
    instance_count          = 2
    ocpus                   = 2
    memory_in_gbs           = 16
    boot_volume_size_in_gbs = 100
    public_ip               = true
    setup_docker            = true
    setup_local_storage     = true
    # ... other configurations
  }
  "cpu-node-private" = {
    shape                   = "VM.Standard.E5.Flex"
    instance_count          = 1
    ocpus                   = 1
    memory_in_gbs           = 8
    boot_volume_size_in_gbs = 50
    public_ip               = false
    setup_docker            = false
    setup_local_storage     = false
    # ... other configurations
  }
  "gpu-node" = {
    shape                   = "VM.GPU.A10.1"
    instance_count          = 1
    boot_volume_size_in_gbs = 200
    setup_docker            = true
    setup_nvidia_docker     = true
    setup_local_storage     = true
    # ... other configurations
  }
}
```

## Deployment

### Initialization
```bash
# Initialize Terraform
terraform init

# View execution plan
terraform plan

# Apply changes
terraform apply
```

### Verification
```bash
# See public IPs of instances
terraform output public_instance_ip

# Connect via SSH
ssh -i keys/oci_instance_key.pem opc@<PUBLIC_IP>
```

## Management

### Useful Commands

#### View State
```bash
# View created resources
terraform state list

# View specific resource details
terraform state show module.compute.oci_core_instance.instances["cpu-node-public-0"]
terraform state show module.compute.oci_core_instance.instances["cpu-node-private-0"]
terraform state show module.compute.oci_core_instance.instances["gpu-node-0"]
```

#### Modify Infrastructure
```bash
# Apply changes
terraform apply

# Destroy specific resources
terraform destroy -target=module.compute.oci_core_instance.instances["gpu-node-0"]
```

#### SSH Access
```bash
# CPU Node Public
ssh -i keys/oci_instance_key.pem opc@<CPU_NODE_PUBLIC_IP>

# CPU Node Private (via bastion or VPN)
ssh -i keys/oci_instance_key.pem opc@<CPU_NODE_PRIVATE_IP>

# GPU Node
ssh -i keys/oci_instance_key.pem opc@<GPU_NODE_IP>
```

## Project Structure

```
.
├── README.md                 # This file
├── main.tf                   # Main configuration
├── variables.tf              # Variable definitions
├── outputs.tf                # Terraform outputs
├── terraform.tfvars          # Variable values
├── locals.tf                 # Local variables
├── data.tf                   # Data sources
├── provider.tf               # Provider configuration
├── keys/                     # Generated SSH keys
│   └── oci_instance_key.pem
└── modules/                  # Terraform modules
    ├── compute/              # Compute module
    ├── network/              # Network module
    └── tools/                # Tools module
```

## Configuration Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `compartment_ocid` | OCI compartment OCID | string | - | ✅ |
| `profile` | OCI CLI profile | string | "DEFAULT" | ❌ |
| `region` | OCI region | string | "sa-saopaulo-1" | ❌ |
| `shapes` | Instance configurations | map(object) | See file | ❌ |

### Shape Configurations

Each shape can be configured with:
- `shape`: Instance type (e.g., VM.Standard.E5.Flex, VM.GPU.A10.1)
- `instance_count`: Number of instances
- `public_ip`: Whether to assign public IP (default: true)
- `ocpus`: Number of vCPUs (flex shapes only)
- `memory_in_gbs`: Memory in GB (flex shapes only)
- `boot_volume_size_in_gbs`: Boot disk size
- `image_id`: Oracle Linux image OCID
- `ssh_user`: SSH user (default: opc)
- `setup_docker`: Install Docker (default: true)
- `setup_nvidia_docker`: Install NVIDIA Docker (default: false)
- `setup_oci_growfs`: Expand file system (default: true)
- `setup_local_storage`: Configure local NVMe storage (default: false)

## Outputs

| Output | Description |
|--------|-------------|
| `public_instance_ip` | List of public IPs for all instances |

## Troubleshooting

### Common Issues

#### Authentication Error
```bash
# Check OCI CLI configuration
cat ~/.oci/config

# Test connectivity
oci iam region list
```

#### Insufficient Quota
- Check service limits in OCI console
- Request quota increase if needed

#### SSH Key Not Found
```bash
# Check if key was generated
ls -la keys/

# If it doesn't exist, run apply again
terraform apply
```

### Logs and Debug
```bash
# Enable detailed logs
export TF_LOG=DEBUG
terraform apply

# View OCI provider specific logs
export TF_LOG_PROVIDER=DEBUG
```

## Security

### Best Practices
- ✅ Automatically generated SSH keys
- ✅ SSH access only via private key
- ✅ Security Groups configured
- ⚠️ **Important**: Keep the `oci_instance_key.pem` file secure

### Exposed Ports
- **SSH (22)**: Administrative access
- Add other ports as needed in the network module

## Cleanup

To destroy all infrastructure:
```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes'
# Remove state files (optional)
rm terraform.tfstate*
```

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

**Built with ❤️ to simplify infrastructure provisioning on Oracle Cloud**

João Speglich - AI Solution Engineer @ Oracle