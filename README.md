# terraform-sandbox-azure
Simple Terraform playground to create an Azure Resource Group and review,

Then to create a Resource Group, Vnet, Subnets, Network Security Group(s) and associated resources and then Azure VM instance(s).

This is an Azure-flavoured version of [terraform-sandbox-aws](https://github.com/wmcdonald404/terraform-sandbox-aws/blob/main/README.md).

## Caveat
This does not demonstrate best practices for Terraform, or public cloud management. It's Just Enough to understand some of the basic concepts, spin up and tear down some simple resources with very few guard rails or controls.

## Prerequisites
You will need the following prerequisites:

1. [An Azure Free or Pay-as-you-go subscription](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#prerequisites)
2. A machine to run Terraform and the Azure CLI at a minimum. You [could use Windows natively](https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash), but WSL or a Linux host will probably be less painful. 
3. Git installed
4. [The Azure CLI installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
5. [Terraform or OpenTofu installed](https://developer.hashicorp.com/terraform/install)

> **Note:** Unless *you know* you need the bleeding edge Terraform, OpenTofu or Azure CLI or related modules, use your distribution's package manager to get started. 

Once you understand the workflow more fully, you can choose an appropriate balance between convenience  and control.

**Convenience** would be an upstream vendor-packaged tooling. e.g. the Fedora, Red Hat, Debian or Ubunty versions of Terraform or Azure CLI.

**Control** would be the source vendor's releases directly from OpenTofu, Hashicorp and/or Microsoft.

## Azure Account Setup
1. Log in to Azure

    ```
    [wmcdonald@fedora ~]$ az login
    ```

2. Complete the browser log in

3. Validate the account/log in status

    ```
    [wmcdonald@fedora ~]$ az account show
    {
        "environmentName": "AzureCloud",
        "homeTenantId": "<home-tennant-id>",
        "id": "<id>>",
        "isDefault": true,
        "managedByTenants": [],
        "name": "Pay-As-You-Go",
        "state": "Enabled",
        "tenantDefaultDomain": "<domain>",
        "tenantDisplayName": "Default Directory",
        "tenantId": "<tennant-id>",
        "user": {
            "name": "<wmcdonald>",
            "type": "user"
        }
    }
    ```

4. Set the `subscription_id` for the target subscription in the environment.

    ```
    [wmcdonald@fedora ~]$ export ARM_SUBSCRIPTION_ID=$(az account show | jq -r '.id')
    [wmcdonald@fedora ~]$ echo $ARM_SUBSCRIPTION_ID
    xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy
    ```

**Note:** This can also be [set in the Terraform code](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference).

## Git Repository
1. Clone the Git repository:
   
    ```
    [wmcdonald@fedora ~ ]$ git clone https://github.com/wmcdonald404/terraform-sandbox-azure 
    ```

2. Switch into the directory:

    ```
    [wmcdonald@fedora ~ ]$ cd terraform-sandbox-azure/
    /home/wmcdonald/terraform-sandbox-azure
    [wmcdonald@fedora terraform-sandbox-azure (main ✓)]$ 
    ```

## Basic Resource Group Creation
1. Switch into the `basic-resource-group` directory

    ```
    [wmcdonald@fedora ~]$ cd ~/terraform-sandbox-azure/basic-resource-group
    ```

2. Check that no resource groups exist in the configured account/subscription

    ```
    [wmcdonald@fedora basic-resource-group]$ az group list
    []
    ```

    > **Note:** Any NetworkWatcherRG entries can be ignored.

3. Review the boilerplate code in `./basic-resource-group/main.tf`:

    ```
    # Configure the Azure provider
    terraform {
        required_providers {
            azurerm = {
                source  = "hashicorp/azurerm"
                # version = "~> 3.0.2"
            }
        }

        # required_version = ">= 1.1.0"
    }

    provider "azurerm" {
        features {}
        # subscription_id = "xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy"
    }

    resource "azurerm_resource_group" "rg" {
        name     = "rg-demo"
        location = "uksouth"
    }
    ```

    > **Note:** traditionally `version` and `required_version` would be explicitly pinned for a provider. Here we have these commented to pull the latest version.

4. Run a Terraform `init`, this will install the required backend and providers:

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform init
    Initializing the backend...
    Initializing provider plugins...
    - Finding latest version of hashicorp/azurerm...
    - Installing hashicorp/azurerm v4.16.0...
    - Installed hashicorp/azurerm v4.16.0 (signed by HashiCorp)
    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

5. Run a Terraform `plan` to review the changes that Terraform _would_ make if/when run: 

    ```
    [wmcdonald@fedora basic-resource-group]$  terraform plan

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # azurerm_resource_group.rg will be created
    + resource "azurerm_resource_group" "rg" {
        + id       = (known after apply)
        + location = "uksouth"
        + name     = "rg-demo"
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
    ```

6. Run the Terraform `apply` to create the resources as configured

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform apply -auto-approve

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # azurerm_resource_group.rg will be created
    + resource "azurerm_resource_group" "rg" {
        + id       = (known after apply)
        + location = "uksouth"
        + name     = "rg-demo"
        }

    Plan: 1 to add, 0 to change, 0 to destroy.
    azurerm_resource_group.rg: Creating...
    azurerm_resource_group.rg: Creation complete after 10s [id=/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```

7. Run a Terraform `show` to review the resources under Terraform management:

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform show
    # azurerm_resource_group.rg:
    resource "azurerm_resource_group" "rg" {
        id         = "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo"
        location   = "uksouth"
        managed_by = null
        name       = "rg-demo"
    }
    ```
8. Re-run the Azure CLI command to review the Azure Resource Groups that exist.

    ```
    [wmcdonald@fedora basic-resource-group]$ az group list
    [
    {
        "id": "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo",
        "location": "uksouth",
        "managedBy": null,
        "name": "rg-demo",
        "properties": {
        "provisioningState": "Succeeded"
        },
        "tags": {},
        "type": "Microsoft.Resources/resourceGroups"
    }
    ]
    ```

9. Log in to the [Azure portal](https://portal.azure.com/#home) and click around to review/visualise what's been created.

10. Run a Terraform `destroy` to clean up the resources we've created:

    > **Note:** if you are working in multiple Azure subscriptions or a real environment, exercise due care and common sense. This **will delete stuff**.

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform destroy -auto-approve
    azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    - destroy

    Terraform will perform the following actions:

    # azurerm_resource_group.rg will be destroyed
    - resource "azurerm_resource_group" "rg" {
        - id         = "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo" -> null
        - location   = "uksouth" -> null
        - name       = "rg-demo" -> null
        - tags       = {} -> null
            # (1 unchanged attribute hidden)
        }

    Plan: 0 to add, 0 to change, 1 to destroy.
    azurerm_resource_group.rg: Destroying... [id=/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo]
    azurerm_resource_group.rg: Still destroying... [id=/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-demo, 10s elapsed]
    azurerm_resource_group.rg: Destruction complete after 17s

    Destroy complete! Resources: 1 destroyed.
    ```

11. Just double-check that the Azure Resource Group is gone using the Azure CLI command as an external validation point:

    ```
    [wmcdonald@fedora basic-resource-group]$ az group list
    []
    ```

12. Log in to the [Azure portal](https://portal.azure.com/#home) again, click around to verify resources have been destroyed.

    > **Note:** The Resource Group may still appear in the Recent section of the portal's landing page but navigate specifically to the [Resource Groups view](https://portal.azure.com/#browse/resourcegroups) to verify the demonstration resource group has been removed.

## Debian VM Creation
1. Switch into the `vm-debian` directory

    ```
    [wmcdonald@fedora ~]$ cd ~/terraform-sandbox-azure/vm-debian
    ```

2. Check that no resource groups or virtual machines exist in the configured account/subscription

    ```
    [wmcdonald@fedora vm-debian]$ az group list
    []
    [wmcdonald@fedora vm-debian]$ az vm list
    []
    ```

    > **Note:** Any NetworkWatcherRG entries can be ignored.

3. Review the boilerplate code in `./vm-debian/main.tf`:

    Note that there are far more resources than in the previous simple resource group example. There's an example graph of resources in `./assets/images/vm-debian-dep-tree.png`

    ![dependency tree](https://github.com/wmcdonald404/terraform-sandbox-azure/blob/main/assets/images/vm-debian-dep-tree.png?raw=true)


4. Run a Terraform `init`, this will install the required backend and providers:

    ```
    [wmcdonald@fedora vm-debian]$ terraform init
    ```

5. Run a Terraform `plan` to review the changes that Terraform _would_ make if/when run: 

    ```
    [wmcdonald@fedora vm-debian]$ terraform plan
    ```

    You can view a limited subset of `plan` output using:
    ```
    [wmcdonald@fedora vm-debian]$ terraform plan | grep -E '( *#)|( *+ name)'
    ```

6. Run the Terraform `apply` to create the resources as configured

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform apply -auto-approve
    ```

    Creation of the VM and the resources it depends on may take a minute or two. At the end the process will `output` the resource group name and public IP for the created instance:

    ```
    Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
    
    Outputs:

    public_ip_address = "172.167.122.193"
    resource_group_name = "rg-debian-demo"
    ```

7. Test connectivity to the virtual machine using the `output` public IP address:

    ```
    [wmcdonald@fedora vm-debian]$ ssh debian@172.167.122.193 -i ~/.ssh/azure_id_rsa
    
    Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
    debian@vm-debian-demo:~$ 
    ```
    
    Once connected, we can validate the VM's access to the [Azure Instance Metadata Service (IMDS)](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=linux)

    ```
    debian@vm-debian-demo:~$ sudo apt-get update
    debian@vm-debian-demo:~$ sudo apt install -y jq
    debian@vm-debian-demo:~$ curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
    ```

8. Run a Terraform `show` to review the resources under Terraform management:

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform show
    ```

9. Re-run the Azure CLI command to review the Azure Resource Group(s) and Virtual Machine(s) that exist.

    ```
    [wmcdonald@fedora vm-debian]$ $ az group list | jq '.[]| .name, .id'
    "NetworkWatcherRG"
    "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/NetworkWatcherRG"
    "rg-debian-demo"
    "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/rg-debian-demo"

    [wmcdonald@fedora vm-debian]$ az vm list | jq '.[]|.name, .hardwareProfile.vmSize'
    "vm-debian-demo"
    "Standard_B1s"
    ```

10. Again log in to the [Azure portal](https://portal.azure.com/#home) and click around to review/visualise what's been created.

11. Run a Terraform `destroy` to clean up the resources we've created:

    > **Note:** if you are working in multiple Azure subscriptions or a real environment, exercise due care and common sense. ONCE AGAIN, this **will delete stuff**.

    ```
    [wmcdonald@fedora basic-resource-group]$ terraform destroy -auto-approve
    Plan: 0 to add, 0 to change, 10 to destroy.
    Destroy complete! Resources: 10 destroyed.
    ```

12. Just double-check that the Azure Resource Group is gone using the Azure CLI command as an external validation point:

    ```
    [wmcdonald@fedora vm-debian]$ $ az group list | jq '.[]| .name, .id'
    "NetworkWatcherRG"
    "/subscriptions/xxxxxxx-nnnn-mmmm-oooo-yyyyyyyyyy/resourceGroups/NetworkWatcherRG"
    
    [wmcdonald@fedora vm-debian]$ az vm list | jq '.[]|.name, .hardwareProfile.vmSize'
    "vm-debian-demo"
    "Standard_B1s"
    ```

    > **Note:** Any NetworkWatcherRG entries can be ignored.

## References
- https://kosztkas.github.io/
- https://github.com/wmcdonald404/terraform-sandbox-aws
- https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure
- https://developer.hashicorp.com/terraform/tutorials/azure-get-started
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform
