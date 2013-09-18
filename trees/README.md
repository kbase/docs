
Phylogenetic Tree and Multiple Sequence Alignment (MSA) Services
=============================================

Overview
----------
This service provides a set of methods for querying, manipulating, and analyzing multiple
sequence alignments and phylogenetic trees.

Authors
---------
Michael Sneddon, LBL (mwsneddon@lbl.gov)
Fangfang Xia, ANL (fangfang.xia@gmail.com)
Matt Henderson, LBL (mhenderson@lbl.gov)


Short log of Release Notes (see RELEASE_NOTES.txt for longer descriptions)
---------
v0.00 - 5/16/2012  - initial repo created
v0.00 - 8/9/2012   - added / tested link to some MO functions and the cpp library
v0.01 - 8/16/2012  - independent deployment and test at build meeting of basic configuration (tested on images v9-14)
v0.02 - 11/20/2012 - prepped for november build, tutorial is now available (tested on image v19)
v0.03 - 2/1/2013   - added scripts and general additional functionality/testing (tested on image v20)
v0.9  - 8/5/2013   - removed dependency on kb_seed, generally cleaned up code


Special deployment instructions
----------
* The Tree service is currently only supported for server deployment in a linux environment.  Only clients and
scripts should be deployed on a Mac.  (to deploy only clients/scripts, use make deploy-client; make deploy-scripts)
* follow the standard KBase deployment and testing procedures


Starting/Stopping the service, and other notes
---------------------------
* to start and stop the service, use the 'start_service' and 'stop_service'
  scripts in (the default location) /kb/deployment/services/trees
* check /kb/deployment/services/trees/log/error.log to see if there were any errors
* on test machines, tree services listen on port 7047, so this port must be open
* after starting the service, the process id of the serivice is stored in the 
  'service.pid' file in /kb/deployment/services/trees
* log files are currently dumped in the /kb/deployment/services/trees/log
  directory, but this will change once central logging is adopted
* the 'reboot_service' is a quick way to 1) stop a running service if it exists,
  redeploy the implementation libs only and 2) start the service again.  It is
  useful for quick debugging and testing.




