.DEFAULT_GOAL := test

SHELL := /bin/bash

cddl ?= $(shell command -v cddl)
ifeq ($(strip $(cddl)),)
  $(error cddl tool not found. To install cddl, run: 'gem install cddl')
endif

diag2cbor ?= $(shell command -v diag2cbor.rb)
ifeq ($(strip $(diag2cbor)),)
  $(error diag2cbor tool not found. To install diag2cbor, run: 'gem install cbor-diag')
endif

CLEANFILES :=

CDDL_FILE := oids.cddl

%.cbor: %.diag ; @$(diag2cbor) $< > $@

DIAG_FILES := $(wildcard *.diag)
CBOR_FILES := $(DIAG_FILES:.diag=.cbor)

CLEANFILES += $(CBOR_FILES)

test: $(CDDL_FILE) $(CBOR_FILES)
	@echo "## testing against CDDL schema ($<)"
	@for f in $(CBOR_FILES); do \
		$(cddl) $< validate $$f &> /dev/null ; \
		case $$f in \
		*GOOD_*) [ $$? -eq 0 ] && echo "[OK] $$f" || echo "!! [KO] $$f" ;; \
		*FAIL_*) [ $$? -ne 0 ] && echo "[OK] $$f" || echo "!! [KO] $$f" ;; \
		esac ; \
	done
.PHONY: test

clean: ; $(RM) $(CLEANFILES)
.PHONY: clean
