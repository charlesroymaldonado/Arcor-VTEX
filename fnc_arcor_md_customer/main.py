import functions_framework
from google.cloud import storage
from google.cloud import bigquery
from google.cloud import exceptions
import os

# prueba de sync entre bitbucket y github

# Construct a BigQuery client object.
client = bigquery.Client()

table_id = os.environ.get("TABLE_ID")


def get_improved_bad_request_exception(
    job: bigquery.job.LoadJob,
) -> exceptions.BadRequest:
    errors = job.errors
    result = exceptions.BadRequest(
        "; ".join([error["message"] for error in errors]), errors=errors
    )
    result._job = job
    return result


# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def handler(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket = data["bucket"]
    source_file = data["name"]

    print(f"Event ID: {event_id}")
    print(f"Event type: {event_type}")
    print(f"Bucket: {bucket}")
    print(f"File: {source_file}")

    uri = "gs://{}/{}".format(bucket, source_file)

    job_config = bigquery.LoadJobConfig()
    job_config.autodetect = False
    job_config.ignore_unknown_values = True
    #  job_config.schema_update_options = [
    #        bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION
    #   ]
    job_config.source_format = bigquery.SourceFormat.NEWLINE_DELIMITED_JSON
    job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
    load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)

    print("Starting job {}".format(load_job.job_id))
    try:
        load_job.result()
    except exceptions.BadRequest as exc:
        raise get_improved_bad_request_exception(load_job) from exc
    print("Job finished.")
