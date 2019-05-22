######### ######### ######### ######### ######### ######### ######### #########

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-vm-public-ip"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  allocation_method   = "Static"
  tags                = "${var.tags}"
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
