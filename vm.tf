######### ######### ######### ######### ######### ######### ######### #########

resource "azurerm_virtual_machine" "main" {
  count                 = 1                                         # create four similar vms
  name                  = "${var.prefix}-vm${count.index}"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_B1ms"

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
    computer_name  = "${var.prefix}-vm${count.index}"
    admin_username = "hcadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path = "/home/hcadmin/.ssh/authorized_keys"

      # key_data = "${file(".ssh/hcadmin_rsa.pub")}"
      key_data = "${var.hcadmin_rsa}"
    }
  }

  tags = "${var.tags}"
}
