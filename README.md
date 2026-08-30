# CyberArk PAS Ansible Lab Environment

This repository contains an automated Infrastructure-as-Code (IaC) deployment for a complete CyberArk Privileged Access Security (PAS) lab environment. It utilizes Ansible to provision virtual machines on a Proxmox hypervisor, build a functional Active Directory domain, and deploy the core CyberArk component stack.

## Architecture Overview

The lab provisions the following infrastructure:
* **Hypervisor:** Proxmox VE
* **Domain:** `lab.cybermark.tech` (Windows Server Domain Controllers)
* **Digital Vaults:** Standalone/Workgroup Windows Servers
* **Core Components:** CPM, PVWA, PSM (Windows Server, Domain Joined)
* **Proxy Components:** PSMP, HTML5 Gateway (Linux, Domain Joined)
* **Network:** Internal segmented lab network (10.0.3.0/24)

## Setting Up the Ansible Control Node

If you are starting with a clean Linux installation, follow these steps to prepare your machine to run this project.

### 1. Install Ansible and Git
**For Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git ansible sshpass
```

**For AlmaLinux/RHEL:**
```bash
sudo dnf install -y epel-release
sudo dnf install -y git ansible-core sshpass
```

### 2. Clone the Repository
```bash
git clone <your-repository-url>
cd cyberark-ansible-lab
```

### 3. Configure the Ansible Vault
This repository relies on encrypted variables for domain configuration and passwords. You must create a local password file so Ansible can decrypt them automatically. 

```bash
# Create the password file (this is ignored by Git)
echo "your_secure_vault_password" > .vault_pass.txt
```

### 4. Install Collection Dependencies
Download the required Ansible modules for Proxmox and Windows AD management:
```bash
ansible-galaxy collection install -r requirements.yml
```

## Prerequisites

1. **Proxmox ISO Staging (CyberArk Binaries):**
   Before running the `20_deploy_files.yml` playbook, you must package all CyberArk installation binaries (`.zip` files) into a single ISO file named `CyberArk_PAS_Installers.iso`. Upload this ISO to the `local` storage pool on your Proxmox host.

2. **KMS Activation Routing:**
   The Windows Server instances use MAS online KMS activation. The provisioning playbook will temporarily switch the VM's DNS to the gateway (`10.0.3.254`) to reach the activation servers before reverting back to the internal Domain Controllers (`10.0.3.1`, `10.0.3.2`). Ensure the gateway has outbound internet access during provisioning.

## Repository Structure

* `inventory/` - Contains host definitions (`hosts.yml`) and group variables (including encrypted `vault.yml` secrets).
* `playbooks/` - Contains the sequential execution playbooks.
* `roles/` - Contains the modular task logic for component deployments.

## Playbook Execution Order

Execute the playbooks in the following sequence to build the environment from scratch:

### Phase 0: Template Generation
* `00_build_win2025_template.yml` - Builds the base Windows Server template (Sysprepped).
* `01_build_alma9_template.yml` - Builds the base AlmaLinux 9 template.

### Phase 1: Infrastructure & Active Directory
* `10_provision_proxmox_vms.yml` - Clones VMs from templates, injects Cloud-Init, sets static IPs, and activates Windows Server via KMS.
* `11_configure_ad_pki.yml` - Promotes DCs, configures DHCP failover, sets up Enterprise PKI, and builds the CyberArk OU/Group structure.
* `12_join_components_ad.yml` - Joins the CPM, PVWA, and PSM servers to the Active Directory domain (excluding isolated Vaults).

### Phase 2: CyberArk Staging & Deployment
* `20_deploy_files.yml` - Hotplugs the `CyberArk_PAS_Installers.iso` to the target component servers via the Proxmox API for zero-network-overhead staging.
* `21_deploy_pre-requirements.yml` - *(Pending)* Installs Windows Features (IIS, RDS) required for components.
* `22_deploy_vaults.yml` - *(Pending)* Installs and hardens the Digital Vaults.
* `23_deploy_pvwa.yml` - *(Pending)* Installs the Password Vault Web Access.
* `24_deploy_cpm.yml` - *(Pending)* Installs the Central Policy Manager.
* `25_deploy_psm.yml` - *(Pending)* Installs the Privileged Session Manager.

### Utilities
* `90_validate_lab.yml` - Runs core AD services health checks and NTLM validation.
* `99_restore_clean_state.yml` - Rolls environment back to base snapshots.
* `666_destroy_lab.yml` - Destroys all lab VMs permanently.

## Quick Start

To begin a fresh deployment after completing the control node setup and prerequisites:

```bash
# 1. Provision the virtual machines
ansible-playbook -i inventory/hosts.yml playbooks/10_provision_proxmox_vms.yml

# 2. Configure Active Directory
ansible-playbook -i inventory/hosts.yml playbooks/11_configure_ad_pki.yml

# 3. Join components to the domain
ansible-playbook -i inventory/hosts.yml playbooks/12_join_components_ad.yml

# 4. Mount installation media
ansible-playbook -i inventory/hosts.yml playbooks/20_deploy_files.yml
```