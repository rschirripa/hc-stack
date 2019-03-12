######### ######### ######### ######### ######### ######### ######### #########

variable "prefix" {
  description = "interrupt-software"
  default = "interrupt-software"
}

variable "location" {
  description = "US East"
  default = "eastus"
}

variable "tags" {
  type        = "map"
  default     = {
                    environment = "test",
                    owner = "gcatill0"
                }
  description = "Basic tags"
}

######### ######### ######### ######### ######### ######### ######### #########

# locals {
#  virtual_machine_name = "${var.prefix}-vm"
#  admin_username       = "testadmin"
#  admin_password       = "Password1234!"
#}

# Azure Provider
provider "azurerm" {
  version = "=1.22.0"
  subscription_id = "0911d9be-4eb1-4324-9588-ec7ac341aaf4"
  tenant_id       = "9b517f7e-90ac-4870-ace7-a6bafa36c304"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  tags                = "${var.tags}"
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "main" {
  name                         = "${var.prefix}-publicip"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  location                     = "${azurerm_resource_group.main.location}"
  allocation_method = "Static"
  tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = "${azurerm_subnet.main.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_virtual_machine" "main" {
    name                  = "${var.prefix}-vm"
    location              = "${azurerm_resource_group.main.location}"
    resource_group_name   = "${azurerm_resource_group.main.name}"
    network_interface_ids = ["${azurerm_network_interface.main.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.prefix}-vm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDblYKh+ouJrYdbzm5gUe5LSpsITRjKTlbRKxBk1iIl3gY1XTUzQb6ixgZh3v+4x1kD6U4AzgpoDRA1xtEWqEWW4K5j9y4Sk/ig8SwwJgCE5T/zB8UJpH6mab5y1w+X/A1PCsAclLDHKFDaB07J2c/3WG6B1J49SY3Wqw41k5VBRs+ABUtDlUr0yqGDaP4WkFx+lfg7kN1CsQMsDmLMRgzj+ag/5ziqrZTTWkYrgVXnYXfvlz0ZiW7tInM8X+Em5AAC83X03f6fx0CYZDnfnabrzyCe7+nHN+ee7Qa2avQhyVN1TgHn5W3yUthqeLfSo6V+eXm3/kK657x2fio5ncd+2SoGfss6awCKVpSqW5sjzYtD9DKOh0NPt9uvlWLgd8a7Thk2b0m1W/qu4f2n5nHnMPdZ7n+Fvtw2j3NHjMPXlrOwpj1apRdQJiUakHoDX+/bkB4TOJgktWuxKbiUJV0u+dmgkS5cmIp5UGLZ+xlxlxT6SgUOfwfsU2jPvCpd6aNt0kQ2PAlGK7wUc8SRzj+oH4xpCN9XtncEiGsWjnB5gSBsnKaBbTFGZpuOuMDW155BfVPuQ1qIA7Dbi6zuphUcZYCf7mCec77c6Th/2mYIfhosDiQTmUBUBMtoYrW+9rwaPBKJBvHXXCNcl+hIGt8sGQjr7A1l7ZCCJf+e7AxAVw== azureuser"
        }
    }

    tags = "${var.tags}"
}
