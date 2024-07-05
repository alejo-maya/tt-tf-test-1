resource "azurerm_resource_group" "setup" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "${lower(var.naming_prefix)}"
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name
}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = local.sas_expiry

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

resource "local_file" "post-config-sa" {
  depends_on = [azurerm_storage_container.ct]

  filename = "${path.module}/${local.state_conf_file}"
  content  = local.backend_config_content
}

resource "local_file" "post-config-app" {
  depends_on = [azurerm_storage_container.ct]

  filename = "${path.module}/${local.app_service_path}/${local.state_conf_file}"
  content  = local.backend_config_content
}