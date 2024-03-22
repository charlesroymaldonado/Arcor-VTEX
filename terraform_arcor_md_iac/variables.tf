variable "project_id" {
    type = string
    default = "arcor-bi-etl-prod"
}

variable "region" {
  default = "us-central1"
}

variable "repo_sources_name" {
    type = string
    description = "Nombre del repositorio de codigo fuentes"
}

variable "environment" {
    type = string
    default = "dev"
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

variable "dataset_id" {
    type = string
  
}

variable "use_legacy_sql" {
  type = string
  default = false
}
