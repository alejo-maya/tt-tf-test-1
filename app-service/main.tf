resource "azurerm_resource_group" "setup" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_service_plan" "sp" {
  name                = "tt-test-app-service-plan"
  resource_group_name = azurerm_resource_group.setup.name
  location            = azurerm_resource_group.setup.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "tt-test-web-app"
  resource_group_name = azurerm_resource_group.setup.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id
  https_only          = true

  site_config {
    always_on = false
    application_stack {
      node_version = "16-lts"
    }
  }
}

