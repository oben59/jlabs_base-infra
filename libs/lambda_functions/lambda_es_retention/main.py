# pylint: disable=missing-docstring,unused-argument,invalid-name,bad-whitespace,singleton-comparison,wrong-import-order,unused-import
from __future__ import print_function
import os
import requests
import json
import time
from datetime import datetime
from dateutil.relativedelta import relativedelta
from urllib2 import Request, urlopen

max_retention = datetime.now() - relativedelta(months=+12)
max_retention_ms = int(time.mktime(max_retention.timetuple()))*1000

es_endpoint = os.environ['es_endpoint']
es_port = os.environ['es_port']
es_prefix = os.environ['es_prefix']
slack_url = os.environ['slack_url']

headers = { "Content-Type": "application/json"}
repo_path = 'http://%s:%s/' %(es_endpoint, es_port)

def handler(event, context):

    cmd = '%s%s_index_results_v2/_delete_by_query' %(repo_path, es_prefix)
    query = '{"query":{"bool":{"must":[{"range":{"published_at":{"lte":%d}}}]}}}' %(int(max_retention_ms))
    r = requests.post(cmd, data=query, headers=headers)
    r_content = json.loads(r.content)

    # Debug msg
    msg_debug = "delete indexes up to %s : %s %s\n %s" %(max_retention, cmd, query, r.content)
    print(msg_debug)

    # Slack notif
    nb = r_content['deleted']
    notif = "*ES Retention : %s* - delete indexes up to %s : %s - nb : %s" % (es_prefix, max_retention, max_retention_ms, nb)
    req = Request(slack_url, json.dumps({ "text": notif }))
    response = urlopen(req)
    response.read()
