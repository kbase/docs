TARGET ?= /kb/deployment
DEPLOY_RUNTIME ?= /kb/runtime
SERVICE = matR
SERVICE_DIR = $(TARGET)/services/$(SERVICE)
DOC_DIR = $(SERVICE_DIR)/webroot

default:
	echo "everything look good?"

build-libs:
	git submodule init
	git submodule update
	cd matR; git checkout -B maint
	R CMD BATCH install-matr.R

deploy: deploy-client deploy-server

deploy-libs: build-libs

deploy-client: deploy-libs deploy-scripts deploy-docs
	cp matR/README readme.txt

deploy-scripts:
	echo "No scripts to install"

deploy-server:
	echo "No server to install"

deploy-docs:
	-mkdir $(SERVICE_DIR)
	-rm $(DOC_DIR)/README.md
	-rm $(DOC_DIR)/DESCRIPTION.md
	-mkdir $(DOC_DIR)
	cp matR/README $(DOC_DIR)/README.md
	cp matR/DESCRIPTION $(DOC_DIR)/DESCRIPTION.md

test: test-server test-scripts test-client

test-client:
	echo "No automatic client tests yet, manually run 'demo'. See readme.txt."

test-scripts:
	echo "No scripts to test"

test-server:
	echo "No server to test"
