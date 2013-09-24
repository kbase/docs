##################################################################################
# configurable variables which can be updated
SERVICE = trees
SERV_SERVICE = trees
SERVICE_NAME = Tree
SERVICE_PSGI_FILE = Tree.psgi
SERVICE_PORT = 7047

##################################################################################
#Additional configuration variables which are pulled from the environment
TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

#for the reboot_service script, we need to get a path to dev_container/modules/trees.  We can do this  simply
#by getting the absolute path to this makefile.  Note that old versions of make might not support this line.
ROOT_DEV_MODULE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# including the common makefile gives us a handle to the service directory.  This is
# where we will (for now) dump the service log files
include $(TOP_DIR)/tools/Makefile.common
$(SERVICE_DIR) ?= /kb/deployment/services/$(SERVICE)
PID_FILE = $(SERVICE_DIR)/service.pid
ACCESS_LOG_FILE = $(SERVICE_DIR)/log/access.log
ERR_LOG_FILE = $(SERVICE_DIR)/log/error.log

.PHONY : test

##################################################################################
# default target is all, which compiles the typespec and builds documentation
default: all

all: compile-typespec  build-docs  build-dev-container-script-wrappers  COMMANDS

compile-typespec:
	mkdir -p lib/biokbase/$(SERVICE_NAME)
	mkdir -p lib/javascript/$(SERVICE_NAME)
	mkdir -p scripts
	compile_typespec \
		--psgi $(SERVICE_PSGI_FILE) \
		--impl Bio::KBase::$(SERVICE_NAME)::$(SERVICE_NAME)Impl \
		--service Bio::KBase::$(SERVICE_NAME)::Service \
		--client Bio::KBase::$(SERVICE_NAME)::Client \
		--py biokbase/$(SERVICE_NAME)/Client \
		--js javascript/$(SERVICE_NAME)/Client \
		--url https://kbase.us/services/tree \
		$(SERVICE_NAME).spec lib
	rm -f lib/Tree*.py

build-docs: compile-typespec
	mkdir -p docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/Client.pm --outfile=docs/$(SERVICE_NAME).html
	rm -f pod2htmd.tmp

# building the CPP libs amounts to calling another makefile in the KBTree_cpp_lib directory
cpp-lib:
	cd lib/KBTree_cpp_lib; make all DEPLOY_RUNTIME=$(DEPLOY_RUNTIME);


# creates script wrappers in dev_container/bin without copying scripts (this is
# how compile_typespec and kb_seed scripts are put on the path after ‘make’
build-dev-container-script-wrappers:
	$(TOOLS_DIR)/deploy-wrappers \
		--jsonCommandsFile COMMANDS.json \
		--target $(TOP_DIR) \
		--no-copyScripts \
		--devContainerToolsDir $(TOOLS_DIR)

COMMANDS: COMMANDS.json
	$(TOOLS_DIR)/deploy-wrappers \
		--jsonCommandsFile COMMANDS.json \
		--irisCommandsFile COMMANDS \
		--devContainerToolsDir $(TOOLS_DIR)







# You can change these if you are putting your tests somewhere
# else or if you are not using the standard .t suffix
CLIENT_TESTS = $(wildcard t/client-tests/*.t)
SCRIPT_TESTS = $(wildcard t/script-tests/*.t)


##################################################################################
# here are the standard KBase test targets (test, test-all, deploy-client, deploy-scripts, & deploy-service)
test: test-client test-scripts
	echo "running client and script tests"

test-all: test-service test-client test-scripts

test-client:
	echo "running client tests"
	# run each test
	export TREE_DEPLOYMENT_CONFIG=$(ROOT_DEV_MODULE_DIR)/deploy.cfg; \
	export TREE_DEPLOYMENT_SERVICE_NAME=$(SERVICE); \
	for t in $(CLIENT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done


test-scripts:
	echo "running script tests"
	# run each test
	export TREE_DEPLOYMENT_CONFIG=$(ROOT_DEV_MODULE_DIR)/deploy.cfg; \
	export TREE_DEPLOYMENT_SERVICE_NAME=$(SERVICE); \
	for t in $(SCRIPT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

	
test-service:
	$(DEPLOY_RUNTIME)/bin/perl t/server-tests/testServerUp.t





##################################################################################
# here are the standard KBase deployment targets (deploy, deploy-all, deploy-client, deploy-scripts, & deploy-service)
deploy: deploy-all

deploy-all: deploy-client deploy-service deploy-scripts deploy-docs
	echo "OK... Done deploying ALL artifacts (includes clients, docs, scripts and service) of $(SERVICE)."
	
deploy-client:
	mkdir -p $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)
	mkdir -p $(TARGET)/lib/biokbase/$(SERVICE_NAME)
	mkdir -p $(TARGET)/lib/javascript/$(SERVICE_NAME)
	touch lib/biokbase/__init__.py #do not include code in biokbase/__init__.py
	touch lib/biokbase/$(SERVICE_NAME)/__init__.py
	cp lib/Bio/KBase/$(SERVICE_NAME)/Client.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/Bio/KBase/$(SERVICE_NAME)/Util.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/biokbase/$(SERVICE_NAME)/* $(TARGET)/lib/biokbase/$(SERVICE_NAME)/.
	cp lib/javascript/$(SERVICE_NAME)/* $(TARGET)/lib/javascript/$(SERVICE_NAME)/.
	echo "deployed clients of $(SERVICE)."
	
deploy-scripts:
	$(TOOLS_DIR)/deploy-wrappers \
		--jsonCommandsFile COMMANDS.json \
		--target $(TARGET) \
		--devContainerToolsDir $(TOOLS_DIR)

deploy-docs:
	mkdir -p $(SERVICE_DIR)/webroot
	cp docs/*.html $(SERVICE_DIR)/webroot/.

# deploys all libraries and scripts needed to start the service
deploy-service: cpp-lib deploy-service-libs deploy-service-start_scripts

deploy-service-libs:
	# copy over the general purpose libs
	mkdir -p $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)
	mkdir -p $(SERVICE_DIR)
	cp lib/Bio/KBase/$(SERVICE_NAME)/Service.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/Bio/KBase/$(SERVICE_NAME)/$(SERVICE_NAME)Impl.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/$(SERVICE_PSGI_FILE) $(TARGET)/lib/.
	cp deploy.cfg $(SERVICE_DIR)/.
	# copy over tree specific libs
	cp lib/KBTree_cpp_lib/lib/perl_interface/Bio/KBase/$(SERVICE_NAME)/TreeCppUtil.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	-cp lib/KBTree_cpp_lib/lib/perl_interface/TreeCppUtil.so $(TARGET)/lib/.
	cp lib/Bio/KBase/$(SERVICE_NAME)/ForesterParserWrapper.pm $(TARGET)/lib/Bio/KBase/Tree/.
	cp lib/forester_1005.jar $(TARGET)/lib/.
	cp lib/Bio/KBase/$(SERVICE_NAME)/Util.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	cp lib/Bio/KBase/$(SERVICE_NAME)/Community.pm $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)/.
	echo "deployed service for $(SERVICE)."

# creates start/stop/reboot scripts and copies them to the deployment target
deploy-service-start_scripts:
	# First create the start script (should be a better way to do this...)
	echo '#!/bin/sh' > ./start_service
	echo "echo starting $(SERVICE) service." >> ./start_service
	echo 'export PERL5LIB=$$PERL5LIB:$(TARGET)/lib' >> ./start_service
	echo "export FILE_TYPE_DEF_FILE=$(FILE_TYPE_DEF_FILE)" >> ./start_service
	echo "export TREE_DEPLOYMENT_CONFIG=$(SERVICE_DIR)/deploy.cfg" >> ./start_service
	echo "export TREE_DEPLOYMENT_SERVICE_NAME=$(SERVICE)" >> ./start_service
	echo "$(DEPLOY_RUNTIME)/bin/starman --listen :$(SERVICE_PORT) --pid $(PID_FILE) --daemonize \\" >> ./start_service
	echo "  --access-log $(ACCESS_LOG_FILE) \\" >>./start_service
	echo "  --error-log $(ERR_LOG_FILE) \\" >> ./start_service
	echo "  $(TARGET)/lib/$(SERVICE_PSGI_FILE)" >> ./start_service
	echo "echo $(SERVICE_NAME) service is listening on port $(SERVICE_PORT).\n" >> ./start_service
	# Second, create a debug start script that is not daemonized
	echo '#!/bin/sh' > ./debug_start_service
	echo 'export PERL5LIB=$$PERL5LIB:$(TARGET)/lib' >> ./debug_start_service
	echo 'export STARMAN_DEBUG=1' >> ./debug_start_service
	echo "export TREE_DEPLOYMENT_CONFIG=$(SERVICE_DIR)/deploy.cfg" >> ./debug_start_service
	echo "export TREE_DEPLOYMENT_SERVICE_NAME=$(SERVICE)" >> ./debug_start_service
	echo "$(DEPLOY_RUNTIME)/bin/starman --listen :$(SERVICE_PORT) --workers 1 \\" >> ./debug_start_service
	echo "    $(TARGET)/lib/$(SERVICE_PSGI_FILE)" >> ./debug_start_service
	# Third create the stop script
	echo '#!/bin/sh' > ./stop_service
	echo "echo trying to stop $(SERVICE) service." >> ./stop_service
	echo "pid_file=$(PID_FILE)" >> ./stop_service
	echo "if [ ! -f \$$pid_file ] ; then " >> ./stop_service
	echo "\techo \"No pid file: \$$pid_file found for service $(SERVICE_NAME).\"\n\texit 1\nfi" >> ./stop_service
	echo "pid=\$$(cat \$$pid_file)\nkill \$$pid\n" >> ./stop_service
	# Finally create a script to reboot the service by stopping, redeploying the service, and starting again
	echo '#!/bin/sh' > ./reboot_service
	echo '# auto-generated script to stop the service, redeploy service implementation, and start the servce' >> ./reboot_service
	echo "./stop_service\ncd $(ROOT_DEV_MODULE_DIR)\nmake deploy-service-libs\ncd -\n./start_service" >> ./reboot_service
	# Actually run the deployment of these scripts
	chmod +x start_service stop_service reboot_service debug_start_service
	mkdir -p $(SERVICE_DIR)
	mkdir -p $(SERVICE_DIR)/log
	cp start_service $(SERVICE_DIR)/
	cp debug_start_service $(SERVICE_DIR)/
	cp stop_service $(SERVICE_DIR)/
	cp reboot_service $(SERVICE_DIR)/


# this undeploy target is a custom hack for Trees
undeploy: undeploy-script-wrappers
	#undeploy standard stuff
	rm -rfv $(SERVICE_DIR)
	rm -rfv $(TARGET)/lib/Bio/KBase/$(SERVICE_NAME)
	rm -rfv $(TARGET)/lib/$(SERVICE_PSGI_FILE)
	rm -rfv $(TARGET)/lib/biokbase/$(SERVICE_NAME)
	rm -rfv $(TARGET)/lib/javascript/$(SERVICE_NAME)
	#undeploy custom libs
	rm -rfv $(TARGET)/lib/TreeCppUtil.so
	rm -fv  $(TARGET)/lib/forester_1005.jar
	echo "OK ... Removed all deployed files."

undeploy-script-wrappers:
	$(TOOLS_DIR)/deploy-wrappers \
		--jsonCommandsFile COMMANDS.json \
		--target $(TARGET) \
		--devContainerToolsDir $(TOOLS_DIR) \
		--undeploy


# remove files generated within this directory and dev_container/bin
clean: clean-dev-container-script-wrappers
	cd lib/KBTree_cpp_lib; make clean DEPLOY_RUNTIME=$(DEPLOY_RUNTIME);
	rm -f lib/Bio/KBase/$(SERVICE_NAME)/Client.pm
	rm -f lib/Bio/KBase/$(SERVICE_NAME)/Service.pm
	rm -f lib/$(SERVICE_PSGI_FILE)
	rm -rf lib/biokbase
	rm -rf lib/javascript
	rm -rf docs
	rm -f start_service stop_service reboot_service debug_start_service

clean-dev-container-script-wrappers:
	$(TOOLS_DIR)/deploy-wrappers \
		--jsonCommandsFile COMMANDS.json \
		--target $(TOP_DIR) \
		--no-copyScripts \
		--devContainerToolsDir $(TOOLS_DIR) \
		--undeploy