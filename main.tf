provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azvm-rg" {
  name     = "azvm-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "azvnet" {
  name                = "azvnet"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.azvm-rg.location
  resource_group_name = azurerm_resource_group.azvm-rg.name
}

resource "azurerm_subnet" "azsubnet1" {
  name                 = "azsubnet1"
  resource_group_name  = azurerm_resource_group.azvm-rg.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_network_interface" "aznetinterface" {
  name                = "aznetinterface-nic"
  location            = azurerm_resource_group.azvm-rg.location
  resource_group_name = azurerm_resource_group.azvm-rg.name
 # Private_ip_iddress_allocation = "Dynamic"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azsubnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "winvm0" {
  name                = "winvm0"
  resource_group_name = azurerm_resource_group.azvm-rg.name
  location            = azurerm_resource_group.azvm-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.aznetinterface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
