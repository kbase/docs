
This is the test directory for the alignment and phylogenetic tree services.
=================================================================================

To run the tests:
---------------------------
 - Enter the top-level directory of the trees module in dev_container/modules.
 - To deploy the server on localhost, follow deployment instructions in the top-level readme file
 - If testing a server on a remote host or non-default port, then edit te TreeTestConfig.pm module to
   configure the correct host url and port number.  This module is used by all perl tests.
 - Make sure that the Tree client libraries are deployed if running the client-tests
 - Make sure that the correct perl paths are set by running "source user-env.sh" in the deployment
   directory.
 - From the top-level directory of the trees module, type "make test-all" to run all tests.  Other
   test targets are also available to selectively test clients, scripts, or the server indepedently.
   See the makefile for details.
 

To add a new test:
---------------------------
 - create a new file in the appropriate directory (either "t/client-tests", "t/script-tests",
   or "t/server-tests") OR open an existing test script file.
 - if creating a new test file, add the name of the file to the list of available tests below and
   add the command to run the script under the appropriate makefile target in the trees makefile
 - if creating a new test file in perl, use the module TreeTestConfig to properly configure the
   host url and port information.  See t/server-tests/testServerUp.t for an example.


Available Tests:
----------------------------

    client-tests: (tests which use the Tree Service client in the 'lib' directory)
        - testBasicResponses.t - using the perl client, makes sure that the service responds to all defined methods
        - testQueryMethods.t - test suite for the set of methods that query the CDM for tree/alignment data
        - testIntrospectionMethods.t - test suit for methods which take a tree as input and compute properties of the tree
    
    script-tests: (tests which call scripts in the 'scripts' directory)
    (none at this time because there are no scripts to deploy)
    
    server-tests: (tests which connect directly to a server without invoking the Tree service client)
        - testServerUp.t - simple diagnostic to connect to a url to see if it is properly running a Tree server







