######### ######### ######### ######### ######### ######### ######### #########
# V 0.7
#
variable "prefix" {
  description = "Interrupt Software"
  default     = "interrupt-software"
}

variable "node_no" {
  default = "1"
}

variable "location" {
  description = "East US"
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
