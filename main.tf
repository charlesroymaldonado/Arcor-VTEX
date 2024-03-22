provider "google" {
  credentials = file("${var.credentials}")
  project = var.project_id
  region  = var.region
}

module "orders_fnc_repo" {
  source = "./orders_fnc_repo"
}

module "arcor_common_iac"{
  source = "./terraform_common_iac"
  project_id = var.project_id
  environment = var.environment
  repo_sources = var.repo_sources
  region = var.region
}

module "arcor_orders_iac" {
    source = "./terraform_arcor_orders_iac"
    project_id = var.project_id
    environment = var.environment
    repo_sources_name = module.arcor_common_iac.repo_sources_name
    region = var.region
    order_raw_bkt_name = var.order_raw_bkt_name
    order_config_bkt_name = var.order_config_bkt_name
    orders_topic_name = var.orders_topic_name
    service_account_publisher = var.service_account_publisher

    fnc_orders_subscriptor_zip_file = var.fnc_orders_subscriptor_zip_file
    fnc_orders_process_zip_file = var.fnc_orders_process_zip_file
    table_order_id = var.table_order_id
    table_order_view_id = var.table_order_view_id
    schema_json_order = var.schema_json_order
    query_orders = var.query_orders

}

module "arcor_md_iac" {
    source = "./terraform_arcor_md_iac"
    project_id = var.project_id
    environment = var.environment
    region = var.region
    md_raw_bkt_name = var.md_raw_bkt_name
    fnc_customer_zip_file = var.fnc_customer_zip_file
    table_customers_id = var.table_customers_id    
    table_customers_view_id = var.table_customers_view_id    
    repo_sources_name = module.arcor_common_iac.repo_sources_name
    dataset_id = module.arcor_orders_iac.dataset_id
    query_customers = var.query_customers

}
