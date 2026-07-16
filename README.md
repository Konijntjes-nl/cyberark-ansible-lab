# Automated CyberArk & Active Directory Lab Provisioning

This repository contains a fully automated, Infrastructure-as-Code (IaC) deployment pipeline for provisioning a clustered Active Directory environment and pre-staging a CyberArk Privileged Access Management (PAM) architecture on Proxmox VE.

## 🏗️ Architecture Overview

The automation handles end-to-end deployment, moving from bare-metal VM clones to a fully functional, highly available corporate domain in minutes.

* **Hypervisor:** Proxmox VE cluster (utilizing local LVM storage and Cloudbase-Init).
* **Domain:** `lab.cybermark.tech`
* **Provisioning Method:** Zero-touch Windows Sysprep utilizing Cloudbase-Init with NoCloud ConfigDrive metadata injection.
* **Core Infrastructure:**
  * Primary and Secondary Windows Server 2025 Domain Controllers (`dc-01`, `dc-02`).
  * Clustered DHCP Failover (Hot Standby).
  * Enterprise Root Certificate Authority (AD CS) for PKI.
* **CyberArk Pre-Staging:**
  * Dedicated Organizational Units (Tier 0, Tier 1, Infrastructure, CyberArk_Roles).
  * Role-Based Access Control (RBAC) Security Groups.
  * Component VMs pre-allocated via DHCP reservations (Vault, PVWA, CPM, PSM, PSMP, HTMLGW).

---

## 🚀 Current Capabilities (What this repo does today)

### 1. Image Bakery (Windows Server 2025)
* Automates the creation of a Windows Server 2025 Golden Image on Proxmox.
* Injects **Cloudbase-Init** configured specifically to bypass OpenStack network timeouts and natively discover Proxmox CD-ROMs using the `NoCloudConfigDriveService`.
* Pre-arms the OS to execute PowerShell user-data scripts on first boot to dynamically set hostnames, static IPs, and vault Administrator passwords.

### 2. Proxmox Infrastructure Provisioning
* Uses the Proxmox API to dynamically clone templates into live VMs.
* Generates and mounts custom Cloud-Init ISO snippets on the fly to pass variables (IP, Gateway, Hostname) directly to the booting clones.
* Automatically waits for WinRM ports to open before proceeding.

### 3. Active Directory & PKI Bootstrap
* Promotes `dc-01` to Primary Domain Controller and `dc-02` to Secondary.
* Configures DHCP scopes and Hot Standby failover.
* Installs an Enterprise Root CA, configures certificate templates, and publishes a highly available Certificate Revocation List (CRL) via IIS.

### 4. CyberArk AD Foundation
* Scaffolds a production-grade AD structure based on Tiered administration (Tier 0 / Tier 1).
* Creates production identities (Vault Admins, Windows Admins, Auditors, Service Accounts).
* Pre-stages computer objects for all upcoming CyberArk component servers.

### 5. Automated Lab Validation
* Executes a strict health-check playbook using Domain Admin WinRM credentials.
* Verifies AD Service states, CRL HTTP reachability, DNS resolution, and OU structure integrity before proceeding to software installation.

---

## 🗺️ Future Roadmap (Work in Progress)

The following features are slated for upcoming releases to complete the CyberArk PAM deployment:

* **Automated Domain Joins**
  * Automatically join all CyberArk Component servers (PVWA, CPM, PSM, HTMLGW) to `lab.cybermark.tech`.
  * *Strictly excludes Digital Vaults (which must remain isolated Workgroup machines) and Linux servers.*
* **CyberArk Component Rollouts**
  * Component-specific Ansible playbooks leveraging the official CyberArk roles.
  * Automated silent installation of the Password Vault Web Access (PVWA).
  * Automated deployment of the Central Policy Manager (CPM) and Privileged Session Manager (PSM).
* **Digital Vault Architecture**
  * Automated silent installation of the Primary Digital Vault.
  * Implementation of Disaster Recovery (PADR) for an Active-Passive Vault cluster.
* **TBD Enhancements**
  * Automated credential onboarding via REST API.
  * Linux AD integration (SSSD/Realmd).
  * Implementation of PSM for SSH (PSMP).

---

## 🔒 Security & Secrets Management

This repository uses **Ansible Vault** to secure sensitive information.
No plain-text passwords, API tokens, or private keys are stored in the codebase.

To run this lab in your own environment:
1. Copy `inventory/group_vars/all.yml` and fill in your environment specifics.
2. Create an encrypted vault file for your secrets: `ansible-vault create inventory/group_vars/vault.yml`.
3. Ensure you follow the `.gitignore` rules to avoid committing local binaries or unencrypted variable files.
