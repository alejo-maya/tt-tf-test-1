locals {

    sas_expiry = timeadd(timestamp(), "17520h")

    backend_config_content = <<EOF
        storage_account_name = "${azurerm_storage_account.sa.name}"
        container_name = "terraform-state"
        key = "terraform.tfstate"
        sas_token = "${data.azurerm_storage_account_sas.state.sas}"
        EOF

    state_conf_file  = "state.backend.conf"
    app_service_path = "../app-service"

}