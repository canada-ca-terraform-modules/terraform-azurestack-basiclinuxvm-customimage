variable "name" {
  description = "Name of the vm"
}

variable "resource_group_name" {
  description = "Name of the resourcegroup that will contain the VM resources"
}

variable "admin_username" {
  description = "Name of the VM admin account"
}

variable "admin_password" {
  description = "Name of the VM admin account"
}

variable "nic_subnetName" {
  description = "Name of the subnet to which the VM NIC will connect to"
}

variable "nic_vnetName" {
  description = "Name of the VNET the subnet is part of"
}
variable "nic_vnet_resource_group_name" {
  description = "Name of the resourcegroup containing the VNET"
}

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine. Eg: Standard_F4"
}

variable "location" {
  description = "Location of VM"
}

variable "tags" {
  description = "Tags that will be associated to VM resources"
  default = { }
}

variable "data_disk_sizes_gb" {
  description = "List of data disk sizes in gigabytes required for the VM. EG.: If 3 data disks are required then data_disk_size_gb might look like [40,100,60] for disk 1 of 40 GB, disk 2 of 100 GB and disk 3 of 60 GB"
  default     = []
}

variable "disable_password_authentication" {
  description = "description"
  default = "false"
}

variable "dnsServers" {
  description = "List of DNS servers IP addresses to use for this NIC, overrides the VNet-level server list"
  default     = null
}

variable "nic_enable_ip_forwarding" {
  description = "Enables IP Forwarding on the NIC."
  default     = false
}

variable "nic_ip_configuration" {
  description = "Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address"
  default = {
    private_ip_address            = [null]
    private_ip_address_allocation = ["Dynamic"]
  }
}

variable "public_ip" {
  description = "Should the VM be assigned public IP(s). True or false."
  default     = false
}

variable "custom_image_id" {
  description = "The id of the Custom Image to provision this Virtual Machine from."
}

variable "plan" {
  description = "An optional plan block"
  default     = null
}

variable "storage_os_disk" {
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = null
    disk_size_gb  = null
  }
}

variable "ssh_key" {
  description = "description"
  default = null
}

variable "custom_data" {
  description = "Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes."
  default     = null
}

variable "security_rules" {
  type = list(map(string))
  default = [
    {
      name                       = "AllowAllInbound"
      description                = "Allow all in"
      access                     = "Allow"
      priority                   = "100"
      protocol                   = "*"
      direction                  = "Inbound"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowAllOutbound"
      description                = "Allow all out"
      access                     = "Allow"
      priority                   = "105"
      protocol                   = "*"
      direction                  = "Outbound"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "license_type" {
  description = "BYOL license type for those with Azure Hybrid Benefit"
  default     = null
}

variable "boot_diagnostic" {
  default = false
}
