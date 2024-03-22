environment = "dev2"
project_id = "mvp-arcor-dev"
repo_sources = "bkt_arcor_mvp_repo"
repo_remote = "git@github.com:AR-BAS-SOLDIG-INNOVACION/arcor_functions.git"

order_raw_bkt_name = "bkt_orders_raw"
order_config_bkt_name = "bkt_orders_config"
orders_topic_name = "pubsub_topic_orders_vtex"
service_account_publisher = "publish-orders@mvp-arcor-dev.iam.gserviceaccount.com"

fnc_orders_subscriptor_zip_file = "fnc_arcor_orders_subscriptor.zip"
fnc_orders_process_zip_file = "fnc_arcor_orders_process.zip"
table_order_id = "ordenes"
table_order_view_id = "orders"
schema_json_order = "orders_json_schema.json"

md_raw_bkt_name = "bkt_master_data_raw"
fnc_customer_zip_file = "fnc_customer.zip"
table_customers_id = "customers"
table_customers_view_id = "clients"

query_orders = "SELECT Distinct clientProfileData.email, orderId, value/100 AS value,PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S',replace(substr(cast(t1.creationDate as string),1,23),'T',' ')) as creationdate, PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S',replace(substr(cast(t1.lastChange as string),1,23),'T',' ')) as lastChange, status,statusDescription FROM `arcor-bi-etl-prod.arcor_mvp_dataset.ordenes` as t1 WHERE clientProfileData.email IS NOT NULL AND PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S',replace(substr(cast(t1.lastChange as string),1,23),'T',' ')) = (select max(PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E*S',replace(substr(cast(t2.lastChange as string),1,23),'T',' '))) from `arcor-bi-etl-prod.arcor_mvp_dataset.ordenes` as t2 where t1.orderId = t2.orderId AND (t2.statusDescription ) not IN ('Cancelado', 'Cancelamento Solicitado', 'Cancelar','Car?ncia para Cancelamento'))"

query_customers = "SELECT documentType, document, customers.email, userId, firstName, lastName, tradeName, country, homePhone, birthDate, birthDateMonth, gender, isCorporate, corporateDocument, corporateName, businessPhone, sellers, cluster1, cluster2, cluster3, cluster4 FROM `arcor-bi-etl-prod.arcor_mvp_dataset.customers` as customers WHERE customers.email IS NOT NULL AND userId IS NOT NULL"