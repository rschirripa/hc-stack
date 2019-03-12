######### ######### ######### ######### ######### ######### ######### #########
# V 0.5
#
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
        name              = "${var.prefix}-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04.0-LTS"
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
            key_data = "${file("~/Hashicorp/my-infra/azure/.ssh/azure_rsa.pub")}"
        }
    }

    tags = "${var.tags}"
}
