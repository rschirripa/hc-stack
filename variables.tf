######### ######### ######### ######### ######### ######### ######### #########
# V 0.7
#
variable "prefix" {
  description = "Interrupt Software"
  default     = "raff_demo1"
}

variable "location" {
  description = "East US"
  default     = "eastus"
}

variable "tags" {
  type = "map"

  default = {
    environment = "IS Test"
    owner       = "rschirripa"
    expiry	= "1 day"
  }



  description = "Basic tags"
}

variable "hcadmin_rsa" {
  description = "Access certificate for VM"
}
