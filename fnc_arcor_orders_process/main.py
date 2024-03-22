import functions_framework
from google.cloud import storage
import json 
import os
from orders_transform import transform

from google.cloud import bigquery

# Construct a BigQuery client object.
client = bigquery.Client()

table_id = os.environ.get('TABLE_ID')
print(f"table_id: {table_id}")

repo_config_bucket = os.environ.get('CONFIG_BUCKET')
orders_schema = os.environ.get('ORDERS_SCHEMA')

storage_client = storage.Client()

def get_orders_schema():
    bucket = storage_client.bucket(repo_config_bucket)
    blob = bucket.blob(orders_schema)
 
    # read as string
    read_output = blob.download_as_string()

    json_schema_file = json.loads(read_output)

    return json_schema_file




# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def handler(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket_name = data["bucket"]
    file_name = data["name"]

    # TODO: pasar a logging debug
    print(f"Event ID: {event_id}")
    print(f"Event type: {event_type}")
    print(f"Bucket: {bucket_name}")
    print(f"File: {file_name}")


    
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
 
    # read as string
    read_output = blob.download_as_string()

    # TODO: pasar a logging debug
    print(
        "File {} read successfully  from Bucket  {}.".format(
            file_name, bucket_name
        )
    )

    result = []

    json_order = json.loads(read_output)

    print(f"Json: {json_order}")  

    json_schema = get_orders_schema()

    json_result = transform(json_order, json_schema)    

    result.append(json_result)
    
    errors = client.insert_rows_json(table_id, result)  
    if errors == []:
        print("New rows have been added.")
    else:
        print("Encountered errors while inserting rows: {}".format(errors))
