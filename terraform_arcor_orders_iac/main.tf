



data "archive_file" "source_orders_subscriptor" {
   type        = "zip"
   output_path = "./.builds/${var.fnc_orders_subscriptor_zip_file}"
   source_dir = "./orders_fnc_repo/${var.repo_orders_subscriptor}"
}

data "archive_file" "source_orders_process" {
   type        = "zip"
   output_path = "./.builds/${var.fnc_orders_process_zip_file}"
   source_dir = "./orders_fnc_repo/${var.repo_orders_process}"
}

#Cloud Storage - Buckets
resource "google_storage_bucket" "orders_raw" {
    name = "${var.order_raw_bkt_name}_${var.environment}"
    storage_class = "REGIONAL"
    location = var.region
}

resource "google_storage_bucket" "order_config" {
    name = "${var.order_config_bkt_name}_${var.environment}"
    storage_class = "REGIONAL"
    location = var.region
}


#Cloud Storage - Objects
resource "google_storage_bucket_object" "fnc_orders_subscriptor_object" {
  name   = format("%s_%s%s", replace(var.fnc_orders_subscriptor_zip_file, ".zip", ""), data.archive_file.source_orders_subscriptor.output_md5, ".zip")
  bucket = var.repo_sources_name
  source = data.archive_file.source_orders_subscriptor.output_path # Add path to the zipped function source code
}

resource "google_storage_bucket_object" "fnc_orders_process_object" {
  name   = format("%s_%s%s", replace(var.fnc_orders_process_zip_file, ".zip", ""), data.archive_file.source_orders_process.output_md5, ".zip")
  bucket = var.repo_sources_name
  source = data.archive_file.source_orders_process.output_path  # Add path to the zipped function source code
}

resource "google_storage_bucket_object" "fnc_orders_config_object" {
  name   = var.schema_json_order
  bucket = google_storage_bucket.order_config.name
  source = "./terraform_arcor_orders_iac/${var.schema_json_order}" 
}

#PUBSUB - Orders Topic 
resource "google_pubsub_topic" "orders_topic" {
  project = "${var.project_id}"
  name = var.orders_topic_name
}

resource "time_sleep" "wait_10_seconds" { 
  create_duration = "10s" 
}

resource "google_pubsub_topic_iam_binding" "binding" {
  project = google_pubsub_topic.orders_topic.project
  topic = google_pubsub_topic.orders_topic.name
  role = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${var.service_account_publisher}",
  ]
}

# BigQuery - Table ordenes
resource "google_bigquery_dataset" "arcor_mvp_dataset" {
  dataset_id                  = "${var.arcor_mvp_dataset}"
  project                     = "${var.project_id}"
  friendly_name               = "arcor_mvp"
  description                 = "Ordenes Vtex"
  location                    = "us-central1" 
}

output "dataset_id" {
  value = google_bigquery_dataset.arcor_mvp_dataset.dataset_id
}

resource "google_bigquery_table" "ordenes" {
  dataset_id = "${google_bigquery_dataset.arcor_mvp_dataset.dataset_id}"
  project    = "${var.project_id}"
  table_id   = var.table_order_id
  time_partitioning {
    type = "DAY" 
    field = "${var.time_partitioning_field}"
  }
  schema = "${file("${path.module}/orders_schema_bigquery.json")}"
  
}

resource "google_bigquery_table" "orders" {
  dataset_id = "${google_bigquery_dataset.arcor_mvp_dataset.dataset_id}"
  project    = "${var.project_id}"
  table_id   = "${var.table_order_view_id}"
  view {
    query = "${var.query_orders}"
    use_legacy_sql = "${var.use_legacy_sql}"
  }
  depends_on = [time_sleep.wait_10_seconds]
}

#Function Order Subscription
resource "google_cloudfunctions2_function" "fnc_order_subscriptor" {
  name = "fnc-arcor-order-subscriptor"
  location = var.region
  description = "Esta funcion se subscribe al topico del pubsub que recibe las ordenes de VTEX"
  build_config {
    runtime = "python39"
    entry_point = "handler"  # Set the entry point 
    source {
      storage_source {
        bucket = var.repo_sources_name
        object = google_storage_bucket_object.fnc_orders_subscriptor_object.name
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
        "ORDERS_BUCKET_RAW": google_storage_bucket.orders_raw.name
        "LOG_LEVEL": "INFO"
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true

  }

  event_trigger {
    trigger_region = var.region
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.orders_topic.id
    retry_policy = "RETRY_POLICY_RETRY"
  }
}

# Function order process
resource "google_cloudfunctions2_function" "fnc_order_process" {
  name = "fnc-arcor-order-process"
  location = var.region
  description = "Esta funcion ejecuta el proceso de transformacion y carga de las ordenes"
  build_config {
    runtime = "python39"
    entry_point = "handler"  # Set the entry point 
    source {
      storage_source {
        bucket = var.repo_sources_name
        object = google_storage_bucket_object.fnc_orders_process_object.name
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
      "TABLE_ID": "${var.project_id}.${google_bigquery_table.ordenes.dataset_id}.${var.table_order_id}",
      "CONFIG_BUCKET": google_storage_bucket.order_config.name,
      "ORDERS_SCHEMA": var.schema_json_order
    }
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true

  }

  event_trigger {
    trigger_region = var.region
    event_type =  "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value = google_storage_bucket.orders_raw.name
    }
  }
}