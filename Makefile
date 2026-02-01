## Makefile for packaging and publishing the memos Helm chart (Helm v4)
# Usage:
#  make package      # create a .tgz chart package
#  make oci-push     # push chart to GHCR (requires CR_PAT)

VERSION ?= $(shell grep '^version:' Chart.yaml | head -1 | awk '{print $$2}')
CHART_NAME := memos

GHCR_OWNER ?= ryskn
OCI_REPO ?= oci://ghcr.io/$(GHCR_OWNER)

PACKAGE := $(CHART_NAME)-$(VERSION).tgz

.PHONY: package oci-push clean

package:
	helm package .

oci-push: package
	@if [ -z "$(CR_PAT)" ]; then \
		echo "CR_PAT environment variable is required"; exit 1; \
	fi
	helm registry login ghcr.io -u $(GHCR_OWNER) -p $(CR_PAT)
	helm push $(PACKAGE) $(OCI_REPO)

clean:
	rm -f $(CHART_NAME)-*.tgz
