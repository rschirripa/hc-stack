######### ######### ######### ######### ######### ######### ######### #########

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
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "main" {
  name                         = "${var.prefix}-vm-publicip"
  resource_group_name          = "${azurerm_resource_group.main.name}"
  location                     = "${azurerm_resource_group.main.location}"
  allocation_method            = "Static"
  tags                         = "${var.tags}"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-vm-nic"
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
    vm_size               = "Standard_B1ms"
#    user_data = "${file("config/webconfig.sh")}"

    storage_os_disk {
        name              = "${var.prefix}-vm-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.prefix}-vm"
        admin_username = "hcadmin"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path      = "/home/hcadmin/.ssh/authorized_keys"
            key_data  = "${file(".ssh/hcadmin_rsa.pub")}"
        }
    }

    tags = "${var.tags}"
}

resource "azurerm_virtual_machine_extension" "CustomExtension-basicLinuxBackEnd" {

  name                 = "CustomExtensionBackEnd"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.main.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.5"
  settings             = <<SETTINGS {
        "fileUris": [ "https://raw.githubusercontent.com/gcastill0/hc-stack/master/azure/config/webconfig.sh" ],
        "commandToExecute": "bash webconfig.sh"
        } SETTINGS
  tags = "${var.tags}"
}
