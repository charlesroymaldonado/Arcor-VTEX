import json
import os
import dateutil.parser


# Transforma la orden de acuerdo al esquema json definido
# 
# input: order: dict, orders_schema: dict
# return json_result: dict
def transform(order, orders_schema):

    if not orders_schema.get('properties'):
      return None
    properties_dict = orders_schema['properties']
  
    json_result = {}

    for key in properties_dict:
    #   print (key, '->', properties_dict[key])
        if key in order.keys():
            if key == 'creationDate':
               last_change_dt = dateutil.parser.parse(order[key])
               date_str = last_change_dt.strftime("%Y-%m-%d")
               json_result['datePartition'] = date_str   
            if key == 'clientProfileData':
                json_result[key] = {}
                json_result[key]['email'] = order[key]['email']
            elif type(order[key]) == list or type(order[key]) == dict:
                if type(order[key]) == dict:
                    json_result[key] = transform(order[key], properties_dict[key])
                else:
                    if order[key] == [] or type(order[key][0]) != dict:
                        json_result[key] = order[key]
                    else:
                        json_result[key] = []
                        for element in order[key]:
                            json_result[key].append(transform(element, properties_dict[key]["items"][0]))
            else:
                json_result[key] = order[key]

        else:
            json_result[key] = None
    

    print(json.dumps(json_result))    

    return json_result