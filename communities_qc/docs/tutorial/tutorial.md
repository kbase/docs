<h1>Communities Quality Control Service Tutorial</h1>

<p>This tutorial will give you a quick introduction on how to use the Communities Quality Control Service. The service provides resources for performing quality control on metagenomic sequences.</p>

<h2>Available Resources</h2>

<p>There are currently three resources available</p>

<ul>
<li>drisee</li>
<li>histogram</li>
<li>kmer</li>
</ul>

<p>You can view the available resources by navigating your web browser to the root path of the service. Assuming you are on the machine that runs the service that would normally be port 7052 on localhost: <a href='http://localhost:7052/'>http://localhost:7052/</a>. For the sake of this tutorial, we assume you are on the machine that hosts the service. Otherwise you would replace 'localhost' with the IP/URI of the service machine. This will bring up the resource overview:</p>

```json
{

    "resources": [
        {
            "url": "http://localhost/drisee",
            "name": "drisee"
        },
        {
            "url": "http://localhost/histogram",
            "name": "histogram"
        },
        {
            "url": "http://localhost/kmer",
            "name": "kmer"
        }
    ],
    "version": 1,
    "url": "http://localhost/",
    "contact": "support@kbase.us",
    "description": "RESTful Microbial Communities object and resource API",
    "service": "Microbial Communities QC"

}
```

<p>The drisee resource calculates a drisee score and a drisee profile. The histogram resource provides a basepair histogram for the first one hundred basepairs. The k-mer resource offers statistics on the k-mer distribution within the sequence file.</p>

<h2>Requesting a Computation</h2>

<p>There are multiple ways to request a computation, you could use the client libraries to do a JSON-RPC call, use any REST client, or simply use curl. Before issuing a request, you can take a look at the definition of the resource you want to use. Lets say you want to compute a drisee profile for a metagenomic sequence, you navigate to</p>

<a href='http://localhost:7052/drisee'>http://localhost:7052/drisee</a>

<p>and you should receive</p>

```json
{

    "requests": [
        {
            "parameters": {
                "body": { },
                "required": { },
                "options": { }
            },
            "request": "http://localhost/drisee",
            "name": "info",
            "type": "synchronous",
            "method": "GET",
            "attributes": "self",
            "description": "Returns description of parameters and attributes."
        },
        {
            "parameters": {
                "body": { },
                "required": {
                    "id": [
                        "string",
                        "id of the metagenome to be analyzed"
                    ]
                },
                "options": {
                    "direct_return": [
                        [
                            0,
                            "always return a status token"
                        ],
                        [
                            1,
                            "if the compute is done, return the result data"
                        ]
                    ]
                }
            },
            "request": "http://localhost/drisee/{ID}/compute",
            "name": "compute",
            "type": "asynchronous",
            "method": "GET",
            "attributes": {
                "time": [
                    "string",
                    "computation time of the job at the time of the query"
                ],
                "status": [
                    "string",
                    "status of the compute, one of [ waiting, running, error, complete ]"
                ],
                "error": [
                    "string",
                    "the error message if one ocurred, otherwise an empty string"
                ],
                "id": [
                    "string",
                    "id of the metagenome to be analyzed"
                ]
            },
            "description": "computes quality assessment data of a metagenomic sequence"
        },
        {
            "parameters": {
                "body": { },
                "required": {
                    "id": [
                        "string",
                        "unique object identifier"
                    ]
                },
                "options": { }
            },
            "request": "http://localhost/drisee/{ID}",
            "name": "instance",
            "type": "synchronous",
            "method": "GET",
            "attributes": {
                "count_profile": [ ],
                "version": [
                    "string",
                    "Version of the drisee score "
                ],
                "substitution": [
                    "hash",
                    {
                        "A": [
                            "float",
                            "Error for substitution of A"
                        ],
                        "T": [
                            "float",
                            "Error for substitution of T"
                        ],
                        "N": [
                            "float",
                            "Error for substitution of N"
                        ],
                        "C": [
                            "float",
                            "Error for substitution of V"
                        ],
                        "G": [
                            "float",
                            "Error for substitution of G"
                        ]
                    }
                ],
                "insertion_delition": [
                    "float",
                    "insertion deletion quotient"
                ],
                "created": [
                    "date",
                    "Creation time for this drisee resource"
                ],
                "id": [
                    "string",
                    "Unique ID of the sequence file calculated the drisee error from"
                ],
                "total_errors": [
                    "float",
                    "cumulative drisee error"
                ],
                "percent_profile": [ ]
            },
            "description": "Returns a single object."
        }
    ],
    "url": "http://localhost/drisee",
    "name": "drisee",
    "type": "object",
    "description": "quality assessment of metagenomic sequence"

}
```

<p>Which is a list of all the requests you can make to the drisee resource. The according rpc method name can be constructed by joining method, resource name and request name, so for example the info request would be called 'get_drisee_info'. The parameters are then passed via a hash of parameter name pointing to parameter value.</p>

<p>To request a compute, you need to issue a compute request (sic!). To do so, you need to pass the kbase identifier of the metagenomic sequence you want to analyze. Using curl that would look something like this<p>

```
curl -s -X GET "http://localhost:7052/drisee/kb|mg.1/compute"
```

<p>or in perl you would do</p>

```perl
use LWP::UserAgent;
LWP::UserAgent->new()->get("http://localhost:7052/drisee/kb|mg.1/compute")->content;
```

<p>or you could use the JSON-RPC client for one of the provided languages (which will essentially execute the above line), all of which will return the same result. Since the resource is aynchronous, the return value is not the result, but a status of the request. It will look something like this<p>

```json
{

    "time_seconds": 3,
    "status": "running",
    "error": "",
    "id": "kb|mg.1"

}
```

<p>It will tell you how many seconds the request has been running, what the current status is, an error message (hopefully empty) and an id that you can repeatedly query the status with. When the status turns to 'complete', the return message will look like this</p>

```json
{

    "time_seconds": 0,
    "status": "complete",
    "error": "",
    "id": "kb|mg.1"

}
```

<p>Now you can retrieve the result</p>

```
curl -s -X GET "http://localhost:7052/drisee/kb|mg.1"
```

<p>which should look similar to this</p>

```json
{

    "count_profile": {
        "columns": [ … ],
        "data": [ … ],
        "rows": [ … ]
    },
    "insertion_deletion": 0.990075,
    "version": 1,
    "substitution": {
        "A": 0.880524,
        "T": 0.706725,
        "N": 0,
        "C": 0.897821,
        "G": 0.959598
    },
    "created": "2012-11-30T13:12:50",
    "id": "kb|mg.1",
    "type": "drisee",
    "total_errors": 4.434743,
    "percent_profile": {
        "columns": [
            "A",
            "T",
            "C",
            "G",
            "N",
            "InDel",
            "Total"
        ],
        "data": [ … ],
        "rows": [ … ]
    }

}
```

<p>Note that some of the result has been collapsed for sake of space in this document. Performing these identical steps with exchanging the word 'drisee' for 'kmer' or 'histogram' will return you the results for those resources.</p>

<h2>Authentication</h2>

<p>The results produced by these calculations are stored in the KBase auxiliary store, as are the metagenomic sequences used for computation. If you want your results to be private to you or use private metagenomic sequences that only you have access to in the auxiliary store, you need to use authentication.</p>

<p>The Communities Quality Control Service accepts the standard KBase authentication tokens. They must be sent in the header using the keyword 'auth'. The computation request stated above would then read</p>

```
curl -s -X GET -H "auth: YOUR_KBASE_AUTH_TOKEN_HERE" "http://localhost:7052/drisee/kb|mg.1/compute"
```

<p>This will work with any request and any resource.</p>

<h2>Conclusion</h2>

<p>This concludes this tutorial. If you have any questions or suggestions, please send them to either Andreas Wilke (wilke@mcs.anl.gov) or Tobias Paczian (paczian@mcs.anl.gov).</p>