######### ######### ######### ######### ######### ######### ######### #########

resource "azurerm_virtual_machine_extension" "CustomExtension-basicLinuxBackEnd" {
  name                 = "CustomExtensionBackEnd"
  location             = "${azurerm_resource_group.main.location}"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.main.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.5"

  settings = <<SETTINGS
       {
        "fileUris" : ["https://raw.githubusercontent.com/gcastill0/hc-stack/master/azure/config/webconfig.sh" ],
        "commandToExecute": "bash webconfig.sh"
        }
  SETTINGS

  tags = "${var.tags}"
}
