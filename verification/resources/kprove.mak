# Copied from https://github.com/runtimeverification/verified-smart-contracts
# at commit c1dd484.

#
# Parameters
#

# path to a directory that contains .k.rev and .kevm.rev
DEPS_DIR?=$(ROOT)/deps/wasm-semantics/deps

KEWASM_REPO_DIR?=$(ROOT)

ifndef SPEC_GROUP
$(error SPEC_GROUP is not set)
endif

ifndef SPEC_NAMES
$(error SPEC_NAMES is not set)
endif

SPEC_INI?=spec.ini
TMPLS?=module-tmpl.k spec-tmpl.k

# additional options to kprove command
KPROVE_OPTS?=
KPROVE_OPTS+=$(EXT_KPROVE_OPTS)

# Define variable DEBUG to enable debug options below
# DEBUG=true
ifdef DEBUG
KPROVE_OPTS+=--debug-z3-queries --log-rules
endif

#
# Settings
#

# path to this file
THIS_FILE:=$(abspath $(lastword $(MAKEFILE_LIST)))
# path to root directory
ROOT:=$(abspath $(dir $(THIS_FILE))/../..)
VERIFICATION:=$(ROOT)/verification

RESOURCES:=$(VERIFICATION)/resources
LOCAL_LEMMAS?=verification.k ../resources/kwasm-lemmas.md

SPECS_DIR:=$(VERIFICATION)/specs

K_REPO_DIR:=$(abspath $(DEPS_DIR)/k)

K_BIN:=$(abspath $(K_REPO_DIR)/k-distribution/target/release/k/bin)

KPROVE:=$(K_BIN)/kprove -v --debug -d $(KEWASM_REPO_DIR)/.build/defn/java -m VERIFICATION --z3-impl-timeout 500 \
        --deterministic-functions --no-exc-wrap \
        --cache-func-optimized --no-alpha-renaming --format-failures --boundary-cells k \
        --log-cells k \
        $(KPROVE_OPTS)

SPEC_FILES:=$(patsubst %,$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k,$(SPEC_NAMES))

PANDOC_TANGLE_SUBMODULE:=$(DEPS_DIR)/pandoc-tangle
TANGLER:=$(PANDOC_TANGLE_SUBMODULE)/tangle.lua
LUA_PATH:=$(PANDOC_TANGLE_SUBMODULE)/?.lua;;
export LUA_PATH

#
# Dependencies
#

.PHONY: all clean clean-deps deps split-proof-tests test

all: deps split-proof-tests

clean:
	rm -rf $(SPECS_DIR)

$(TANGLER):
	git submodule update --init -- $(PANDOC_TANGLE_SUBMODULE)

#
# Specs
#

split-proof-tests: $(SPECS_DIR)/$(SPEC_GROUP) $(SPECS_DIR)/lemmas.k $(SPEC_FILES)

$(SPECS_DIR)/$(SPEC_GROUP): $(LOCAL_LEMMAS)
	mkdir -p $@
ifneq ($(strip $(LOCAL_LEMMAS)),)
	cp $(LOCAL_LEMMAS) $@
endif

ifneq ($(wildcard $(SPEC_INI:.ini=.md)),)
$(SPEC_INI): $(SPEC_INI:.ini=.md) $(TANGLER)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".ini" $< > $@
endif

$(SPECS_DIR)/%.k: $(RESOURCES)/%.md $(TANGLER)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) $* $* > $@

#
# Kprove
#

test: $(addsuffix .test,$(SPEC_FILES))

%-spec.k.test: %-spec.k
	$(KPROVE) $<
