import os
import sys
import urllib2
import base64
import json

VERSION = '1'
API_URL = "http://kbase.us/services/communities/"+VERSION
ID_URL  = 'http://www.kbase.us/services/idserver'
OAUTH_URL = 'https://nexus.api.globusonline.org/goauth/token?grant_type=client_credentials'
AUTH_LIST = "Jared Bischof, Travis Harrison, Folker Meyer, Tobias Paczian, Andreas Wilke"

# return python struct from JSON output of MG-RAST API
def obj_from_url(url, auth=None, data=None, debug=False):
    header = {'Accept': 'application/json'}
    if auth:
        header['Auth'] = auth
    if debug:
        print json.dumps(header)
        print url
    try:
        req = urllib2.Request(url, data, headers=header)
        res = urllib2.urlopen(req)
    except urllib2.HTTPError, error:
        try:
            eobj = json.loads(error.read())
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, eobj['ERROR']))
            sys.exit(1)
        except:
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, error.read()))
            sys.exit(1)
    if not res:
        sys.stderr.write("ERROR: no results returned\n")
        sys.exit(1)
    obj = json.loads(res.read())
    if obj is None:
        sys.stderr.write("ERROR: return structure not valid json format\n")
        sys.exit(1)
    if len(obj.keys()) == 0:
        sys.stderr.write("ERROR: no data available\n")
        sys.exit(1)
    if 'ERROR' in obj:
        sys.stderr.write("ERROR: %s\n" %obj['ERROR'])
        sys.exit(1)
    return obj

# print to stdout results of MG-RAST API
def stout_from_url(url, auth=None, data=None, debug=False):
    header = {'Accept': 'text/plain'}
    if auth:
        header['Auth'] = auth
    if debug:
        print json.dumps(header)
        print url
    try:
        req = urllib2.Request(url, data, headers=header)
        res = urllib2.urlopen(req)
    except urllib2.HTTPError, error:
        try:
            eobj = json.loads(error.read())
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, eobj['ERROR']))
            sys.exit(1)
        except:
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, error.read()))
            sys.exit(1)
    if not res:
        sys.stderr.write("ERROR: no results returned\n")
        sys.exit(1)
    while True:
        chunk = res.read(8192)
        if not chunk:
            break
        sys.stderr.write(chunk)

# transform sparse matrix to dense matrix (2D array)
def sparse_to_dense(sMatrix, rmax, cmax):
    dMatrix = [[0 for i in range(cmax)] for j in range(rmax)]
    for sd in sMatrix:
        r, c, v = sd
        dMatrix[r][c] = v
    return dMatrix

# transform BIIOM format to tabbed table
def biom_to_tab(biom, hdl):
    matrix = sparse_to_dense(biom['data'], biom['shape'][0], biom['shape'][1])
    hdl.write( "\t%s\n" %"\t".join([c['id'] for c in biom['columns']]) )
    for i, row in enumerate(matrix):
        hdl.write( "%s\t%s\n" %(biom['rows'][i]['id'], "\t".join([str(r) for r in row])) )

# return MG-RAST id for given KBase id
def kbid_to_mgid(kbid):
    id_map = kbid_lookup([kbid])
    if kbid not in id_map:
        sys.stderr.write("ERROR: '%s' not a valid KBase ID\n" %kbid)
        sys.exit(1)
    return id_map[kbid]

# return list of MG-RAST ids for given list of KBase ids
#  handels mixed ids / all mgrast ids
def kbids_to_mgids(kbids):
    id_map = kbid_lookup(kbids)
    mgids = []
    for i in kbids:
        if i in id_map:
            mgids.append(id_map[i])
        else:
            mgids.append(i)
    return mgids

# return map (KBase id -> MG-RAST id) for given list of KBase ids
def kbid_lookup(kbids):
    params = {'method': 'IDServerAPI.kbase_ids_to_external_ids', 'params': [kbids], 'version': '1.1'}
    data = json.dumps(params)
    try:
        req = urllib2.Request(ID_URL, data)
        res = urllib2.urlopen(req)
    except urllib2.HTTPError, error:
        try:
            eobj = json.loads(error.read())
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, eobj['error']['message']))
            sys.exit(1)
        except:
            sys.stderr.write("ERROR (%s): %s\n" %(error.code, error.read()))
            sys.exit(1)
    if not res:
        sys.stderr.write("ERROR: no results returned for ids (%s)\n" %','.join(kbids))
        sys.exit(1)
    obj = json.loads(res.read())
    if obj is None:
        sys.stderr.write("ERROR: return structure not valid json format\n")
        sys.exit(1)
    if 'error' in obj:
        sys.stderr.write("ERROR: %s\n" %obj['error']['message'])
        sys.exit(1)
    if len(obj['result'][0].keys()) == 0:
        return {}
    else:
        return dict([(k, obj['result'][0][k][1]) for k in obj['result'][0].keys()])

def get_auth_token(opts):
    if 'KB_AUTH_TOKEN' in os.environ:
        return os.environ['KB_AUTH_TOKEN']
    if opts.token:
        return opts.token
    elif opts.user or opts.passwd:
        if opts.user and opts.passwd:
            return token_from_login(opts.user, opts.passwd)
        else:
            sys.stderr.write("ERROR: both username and password are required\n")
            sys.exit(1)
    else:
        return None

def token_from_login(user, passwd, url=OAUTH_URL):
    base64string = base64.b64encode('%s:%s' %(user, passwd)).replace('\n', '')
    header = {'Authorization': 'Basic %s'%base64string}
    try:
        req = urllib2.Request(url, headers=header)
        res = urllib2.urlopen(req)
    except urllib2.HTTPError, error:
        sys.stderr.write("ERROR (%s): %s\n" %(error.code, error.read()))
        sys.exit(1)
    if not res:
        sys.stderr.write("ERROR: could not reach auth server\n")
        sys.exit(1)
    obj = json.loads(res.read())
    if (obj is None) or (len(obj.keys()) == 0) or ('access_token' not in obj):
        sys.stderr.write("ERROR: authentication failed\n")
        sys.exit(1)
    return obj['access_token']
