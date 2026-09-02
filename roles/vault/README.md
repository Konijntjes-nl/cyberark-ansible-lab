# vault - WIP

This Playbook will install the CyberArk Vault & VaultDR software on a Windows 2016 server / VM / instance,
currently supported on Cloud environments only: AWS / Azure

Requirements
------------

- Windows Server 2016/2019/2022/2025 must be installed on the server
- Administrator credentials (either Local or Domain)
- Network connection to the vault and the repository server
- Location of Vault CD image
- PAS packages version 10.8 and above


## Role Variables

A list of vaiables the playbook is using


**Flow Variables**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| os_prerequisites                 | no           | false                                                                          | os prerequisites                         |
| vault_prerequisites              | no           | false                                                                          | vault prerequisites                      |
| vault_extract                    | no           | false                                                                          | vault extract                            |
| vault_install                    | no           | false                                                                          | vault install                            |
| vault_postinstall                | no           | false                                                                          | vault post install                       |
| vaultdr_install                  | no           | false                                                                          | vaultdr install                          |
| vaultdr_postinstall              | no           | false                                                                          | vault post install                       |
| vault_hardening                  | no           | false                                                                          | vault hardening                          |
| vault_clean                      | no           | false                                                                          | vault clean                              |
| vault_activation                 | no           | false                                                                          | vault / dr activation                    |
| vault_role                       | no           | primary                                                                        | vault role (primary/dr)                  |
| platform                         | no           | aws                                                                            | vault on platform (aws/azure)            |
| enable_winrm                     | no           | "no"                                                                           | enable winrm for tests                   |


**Deployment Variables**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| vault_base_bin_drive             | no           | "C:"                                                                           | Base path to extract Vault package       |
| zips_path                        | yes          | None                                                                           | Path to the location of the packages     |
| keys_dir_path                    | yes          | None                                                                           | Path to the location of the keys dir     |
| vault_zip_file_name              | no           | "vault.zip"                                                                    | Zip File name of Vault package           |
| vaultdr_zip_file_name            | no           | "vaultdr.zip"                                                                  | Zip File name of VaultDR package         |
| pacli_zip_file_name              | no           | "pacli.zip"                                                                    | Zip File name of PACLI package           |
| recpub_file_name                 | no           | "recpub.key"                                                                   | Name of the recovery private key file    |
| license_file_name                | no           | "license.xml"                                                                  | Name of the license file                 |
| vault_extract_folder             | no           | "C:\\Cyberark\\packages"                                                       | Path to extract the Vault packages       |
| vault_component_folder           | no           | "Server"                                                                       | The name of vault unzip folder           |
| vaultdr_component_folder         | no           | "Disaster Recovery"                                                            | The name of vaulltdr unzip folder        |
| vault_installation_drive         | no           | "C:"                                                                           | Base drive for installing vault          |
| vault_installation_path          | no           | "C:\\Program Files (x86)\\PrivateArk"                                          | Full path for installing vault           |
| accept_eula                      | yes          | "No"                                                                           | Accepting EULA condition                 |
| vault_admin_password             | yes          | stripped version of ansible_password                                           | Vault Admin password                     |
| vault_master_password            | yes          | stripped version of ansible_password                                           | Vault Master password                    |


**AWS Variables (only if platform is aws)**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| cloud_region                     | no           | us-east-1                                                                      | Region where KMS is present              |


**Azure Variables (only if platform is azure)**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| keyvault_dns_name                | no           | false                                                                          | Azure KeyVault DNS name (including /)    |


**DR Variables**

| Variable                         | Required     | Default                                                                        | Comments                                 |
|----------------------------------|--------------|--------------------------------------------------------------------------------|------------------------------------------|
| vault_primary_ip                 | no           | 1.1.1.1                                                                        | IP Address of the primary vault machine  |
| vault_dr_password                | no           | same as vault_master_password                                                  | Vault DR password                        |


## Usage

**vault_prerequisites**

This task will install the required software in order to deploy vault.

**vault_extract**

This task will extract all the required files into folders and get ready for installation.

**vault_install**

This task will deploy the vault to required folder and validate deployment succeed.

**vault_postinstall**

This task will perform the neccesary operations to make sure vault is active after the installation.

**vaultdr_install**

This task will deploy the vaultdr to required folder and validate deployment succeed.

**vaultdr_postinstall**

This task will perform the neccesary operations to make sure vaultdr is active after the installation.

**vault_hardening**

This task will run the vault hardening process.

**vault_validateparameters**

This task validate which vault steps already occurred on the server so the other tasks won't run again.

**vault_clean**

This task will clean inf files from installation, delete vault installation logs from Temp folder & perform required cleaning processes.

**vault_activation**

This task will change the vault server keys, and perform required proccesses against KMS / Azure KeyVault to register and activate the Vault.

## Example Playbook

Example playbook to show how to call the vault main playbook with several parameters:

    ---
    - hosts: localhost
      connection: local
      tasks:
        - name: Import Vault Role
          ansible.builtin.include_role:
            name: vault
          vars:
            vault_zip_file_path: /tmp/vault.zip
            vaultdr_zip_file_path: /tmp/vaultdr.zip
            pacli_zip_file_path: /tmp/pacli.zip
            recpub_path: /tmp/recpub.key
            license_path: /tmp/license.xml
            vault_extract: true
            vault_prerequisites: true
            vault_install: true
            vault_postinstall: true
            vaultdr_install: true
            vaultdr_postinstall: true
            vault_clean: true
            platform: aws

## License

Apache 2

