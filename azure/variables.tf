######### ######### ######### ######### ######### ######### ######### #########
# V 0.7
#
variable "prefix" {
  description = "Interrupt Software"
  default     = "interrupt-software"
}

variable "location" {
  description = "US East"
  default     = "eastus"
}

variable "tags" {
  type = "map"

  default = {
    environment = "Hashicorp Test"
    owner       = "gcastill0"
  }

  description = "Basic tags"
}
