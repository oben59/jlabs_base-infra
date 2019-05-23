# pylint: disable=missing-docstring,unused-argument,invalid-name,bad-whitespace,singleton-comparison,wrong-import-order,unused-import
from __future__ import print_function
import os
import requests
import json
from datetime import timedelta, datetime, date
from urllib2 import Request, urlopen

snapshot_today = datetime.now()
snapshot_to_purge = snapshot_today - timedelta(days=15)
date_old = snapshot_to_purge.strftime('%Y-%m-%d')
date_new = snapshot_today.strftime('%Y-%m-%d')

es_endpoint = os.environ['es_endpoint']
es_port = os.environ['es_port']
es_s3_repo = os.environ['es_s3_repo']
slack_url = os.environ['slack_url']

def handler(event, context):
    repo_path = 'http://' + es_endpoint + ':' + es_port + '/_snapshot/' + es_s3_repo

    cmd1 = '%s/es_snap_%s' % (repo_path, date_old)
    r1 = requests.delete(cmd1)
    r1_content = json.loads(r1.content)

    cmd2 = '%s/es_snap_%s?wait_for_completion=false' % (repo_path, date_new)
    r2 = requests.put(cmd2)
    r2_content = json.loads(r2.content)

    # Debug msg
    msg_debug = "ES Snapshot : %s\n" % es_s3_repo
    msg_debug += "remove %s : %s\n %s\n" % (date_old, cmd1, r1.content)
    msg_debug += "create %s : %s\n %s\n" % (date_new, cmd2, r2.content)
    print(msg_debug)

    # Slack notif
    bool1 = True if ('accepted' in r1_content and r1_content['accepted'] == True) else False
    bool2 = True if ('accepted' in r2_content and r2_content['accepted'] == True) else False
    notif = "*ES Snapshot : %s* - remove %s : *%s* - create %s : *%s*" % (es_s3_repo, date_old, bool1, date_new, bool2)
    req = Request(slack_url, json.dumps({ "text": notif }))
    response = urlopen(req)
    response.read()
