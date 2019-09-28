data "azurestack_subnet" "subnet" {
  name                 = "${var.nic_subnetName}"
  virtual_network_name = "${var.nic_vnetName}"
  resource_group_name  = "${var.nic_vnet_resource_group_name}"
}

data "azurestack_resource_group" "resourceGroup" {
  name = "${var.resource_group_name}"
}

# we assume that this Custom Image already exists
data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}