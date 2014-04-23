TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

DEPLOY_URL = http://140.221.85.86/docs
DOCS_DIR = docs
DOCS_HOME = $(TARGET)/$(DOCS_DIR)
MODULES = "genome_annotation phispy kb_seed assembly"
TUTORIALS_CFG = tutorials.cfg

default:

test: test-client test-scripts test-service
	@echo "running client and script tests"

test-client:
	echo "no clients to test"

test-scripts:
	echo "no scripts to test"

test-service:
	echo "no service to test"

deploy: deploy-docs

deploy-client:
	echo "no clients to deploy"

deploy-service:
	echo "no service to deploy"

# the excludes need to be moved to a file that is passed to rsync
deploy-docs: deploy-cfg
	rsync -arv --exclude=$(TUTORIALS_CFG) --exclude-from=rsync.ignore ./ $(DOCS_HOME)/

deploy-cfg:
	-mkdir -p $(DOCS_HOME)
	perl ./filter_config.pl -url $(DEPLOY_URL) -n $(MODULES) -i $(TUTORIALS_CFG) > $(DOCS_HOME)/$(TUTORIALS_CFG)
