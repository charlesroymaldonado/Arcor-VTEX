variable "project_id" {
    type = string
    default = "arcor-bi-etl-prod"
}

variable "region" {
  default = "us-central1"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "repo_sources" {
    type = string
    description = "Repositorio de codigo fuentes"
    default = "bkt_arcor_mvp_repo"
}

variable "repo_remote" {
    type = string
}

variable "order_raw_bkt_name" {
    type = string
    default = "bkt_orders_raw"
}

variable "order_config_bkt_name" {
    type = string
    default = "bkt_orders_config"
}


variable "orders_topic_name" {
    type = string
    description = "Nombre del topico donde se publican las ordenes de Vtex"
}

variable "service_account_publisher" {
    type = string
}

variable "fnc_orders_subscriptor_zip_file" {
    type = string
  
}
variable "fnc_orders_process_zip_file" {
    type = string
}
variable "table_order_id" {
    type = string
}

variable "table_order_view_id" {
    type = string
}

variable "query_orders" {
  type = string
}

variable "schema_json_order" {
    type = string
    description = "Esquema de la orden modelado"
}

variable "repo_orders_subscriptor"{
    default = "fnc_arcor_orders_subscriptor"
}
variable repo_orders_process{
    default = "fnc_arcor_orders_process"
}

variable "md_raw_bkt_name" {
    type = string
    
}

variable "fnc_customer_zip_file" {
    type = string
}

variable repo_customer{
    default = "fnc_arcor_md_customer"
}

variable "table_customers_id" {
    type = string
  
}

variable "table_customers_view_id" {
    type = string
  
}


variable "query_customers" {
  type = string
}

variable "credentials" {
    type = string 
}