resource azurestack_network_security_group NSG {
  name                = "${var.name}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dynamic "security_rule" {
    for_each = [for s in var.security_rules : {
      name                       = s.name
      priority                   = s.priority
      direction                  = s.direction
      access                     = s.access
      protocol                   = s.protocol
      source_port_range          = s.source_port_range      #split(",", replace(s.source_port_range, "*", "0-65535"))
      destination_port_range     = s.destination_port_range #split(",", replace(s.destination_port_range, "*", "0-65535"))
      source_address_prefix      = s.source_address_prefix
      destination_address_prefix = s.destination_address_prefix
      description                = s.description
    }]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  tags = "${var.tags}"
}

resource "azurestack_storage_account" "boot_diagnostic" {
  count                    = var.boot_diagnostic ? 1 : 0
  name                     = "${local.storageName}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# If public_ip is true then create resource. If not then do not create any
resource azurestack_public_ip VM-EXT-PubIP {
  count                        = var.public_ip ? length(var.nic_ip_configuration.private_ip_address_allocation) : 0
  name                         = "${var.name}-pip${count.index + 1}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "Static"
  tags                         = "${var.tags}"
}

resource azurestack_network_interface NIC {
  name                          = "${var.name}-nic1"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  enable_ip_forwarding          = "${var.nic_enable_ip_forwarding}"
  network_security_group_id     = "${azurestack_network_security_group.NSG.id}"
  dns_servers                   = "${var.dnsServers}"
  dynamic "ip_configuration" {
    for_each = var.nic_ip_configuration.private_ip_address_allocation
    content {
      name                          = "ipconfig${ip_configuration.key + 1}"
      subnet_id                     = data.azurestack_subnet.subnet.id
      private_ip_address            = var.nic_ip_configuration.private_ip_address[ip_configuration.key]
      private_ip_address_allocation = var.nic_ip_configuration.private_ip_address_allocation[ip_configuration.key]
      public_ip_address_id          = var.public_ip ? azurestack_public_ip.VM-EXT-PubIP[ip_configuration.key].id : ""
      primary                       = ip_configuration.key == 0 ? true : false
    }
  }
  tags = "${var.tags}"
}

resource azurestack_virtual_machine VM {
  name                             = "${var.name}-vm"
  depends_on                       = [var.vm_depends_on]
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  vm_size                          = "${var.vm_size}"
  network_interface_ids            = ["${azurestack_network_interface.NIC.id}"]
  primary_network_interface_id     = "${azurestack_network_interface.NIC.id}"
  delete_data_disks_on_termination = "true"
  delete_os_disk_on_termination    = "true"
  license_type                     = "${var.license_type == null ? null : var.license_type}"
  os_profile {
    computer_name  = "${var.name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${var.custom_data}"
  }
  storage_image_reference {
    id = "${var.custom_image_id}"
  }
  dynamic "plan" {
    for_each = "${local.plan}"
    content {
      name = "${local.plan[0].name}"
      product = "${local.plan[0].product}"
      publisher = "${local.plan[0].publisher}"
    }
  }
  os_profile_linux_config {
    disable_password_authentication = var.disable_password_authentication
    dynamic "ssh_keys" {
      for_each = local.ssh_key
      content {
        key_data = "${local.ssh_key[0]}"
        path = "/home/${var.admin_username}/.ssh/authorized_keys"
      }
    }
  }
  storage_os_disk {
    name          = "${var.name}-osdisk1"
    caching       = "${var.storage_os_disk.caching}"
    create_option = "${var.storage_os_disk.create_option}"
    os_type       = "${var.storage_os_disk.os_type}"
    disk_size_gb  = "${var.storage_os_disk.disk_size_gb}"
  }
  # This is where the magic to dynamically create storage disk operate
  dynamic "storage_data_disk" {
    for_each = "${var.data_disk_sizes_gb}"
    content {
      name          = "${var.name}-datadisk${storage_data_disk.key + 1}"
      create_option = "Empty"
      lun           = "${storage_data_disk.key}"
      disk_size_gb  = "${storage_data_disk.value}"
      caching       = "ReadWrite"
    }
  }
  dynamic "boot_diagnostics" {
    for_each = "${local.boot_diagnostic}"
    content {
      enabled = true
      storage_uri = azurestack_storage_account.boot_diagnostic[0].primary_blob_endpoint
    }
  }
  tags = "${var.tags}"
}