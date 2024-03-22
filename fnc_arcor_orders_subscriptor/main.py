from google.cloud import storage
import base64
from datetime import datetime
import json
import os
import logging
import dateutil.parser

bucket_name = os.environ.get('ORDERS_BUCKET_RAW')
LOG_LEVEL = os.environ["LOG_LEVEL"]
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

def handler(event, context):

     
     pubsub_message = base64.b64decode(event['data']).decode('utf-8')
     message = json.loads(pubsub_message) 

     order_id = message['orderId']
     last_change = message['creationDate']
     last_change_dt = dateutil.parser.parse(last_change)
     path = last_change_dt.strftime("%d-%m-%Y")
     blob_name = path+"/"+"pedido_" + order_id + "_" + datetime.now().strftime("%d-%m-%YT%H:%M:%S:%f")[:-3]

     storage_client = storage.Client()
     bucket = storage_client.bucket(bucket_name)
     blob = bucket.blob(blob_name)

     with blob.open("w") as f:
          f.write(pubsub_message) 
          f.close()
    
     logger.info(f'data message loaded:{blob_name}')