

data "archive_file" "source_customer_process" {
   type        = "zip"
   output_path = "./.builds/${var.fnc_customer_zip_file}"
   source_dir = "./orders_fnc_repo/${var.repo_customer}"    
}

#Cloud Storage - Objects
resource "google_storage_bucket_object" "fnc_customer_process_object" {
  name = format("%s_%s%s", replace(var.fnc_customer_zip_file, ".zip", ""), data.archive_file.source_customer_process.output_md5, ".zip")
  bucket = var.repo_sources_name
  source = data.archive_file.source_customer_process.output_path # Add path to the zipped function source code
}

resource "google_storage_bucket" "md_raw" {
    name = "${var.md_raw_bkt_name}_${var.environment}"
    storage_class = "REGIONAL"
    location = var.region
}

resource "time_sleep" "wait_10_seconds" { 
  create_duration = "10s" 
}

resource "google_bigquery_table" "customers" {
  dataset_id = var.dataset_id
  project    = "${var.project_id}"
  table_id   = var.table_customers_id
  schema = "${file("./terraform_arcor_md_iac/json_cliente_schema.json")}"
}

resource "google_bigquery_table" "clients" {
  dataset_id = var.dataset_id
  project    = "${var.project_id}"
  table_id   = "${var.table_customers_view_id}"
  view {
    query = "${var.query_customers}"
    use_legacy_sql = "${var.use_legacy_sql}"
  }
  depends_on = [time_sleep.wait_10_seconds]
}


# Function customer process
resource "google_cloudfunctions2_function" "fnc_customer_process" {
  name = "fnc-arcor-md-customer-process"
  location = var.region
  description = "Esta funcion ejecuta el proceso de transformacion y carga de los clientes"
  build_config {
    runtime = "python39"
    entry_point = "handler"  # Set the entry point 
    source {
      storage_source {
        bucket = var.repo_sources_name
        object = google_storage_bucket_object.fnc_customer_process_object.name
      }
    }
  }


  service_config {
    max_instance_count  = 100
    min_instance_count = 1
    available_memory    = "256M"
    timeout_seconds     = 60
    max_instance_request_concurrency = 1
    environment_variables = {
      "TABLE_ID": "${var.project_id}.${google_bigquery_table.customers.dataset_id}.${var.table_customers_id}"
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true

  }

  event_trigger {
    trigger_region = var.region
    event_type =  "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value = google_storage_bucket.md_raw.name
    }
  }
}