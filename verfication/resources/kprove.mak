# Copied from https://github.com/runtimeverification/verified-smart-contracts
# at commit c1dd484.

#
# Parameters
#

# path to a directory that contains .k.rev and .kevm.rev
BUILD_DIR?=$(ROOT)/.build

K_REPO_URL?=https://github.com/kframework/k
KEVM_REPO_URL?=https://github.com/kframework/evm-semantics

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

RESOURCES:=$(ROOT)/verification/resources
LOCAL_LEMMAS?=verification.k

SPECS_DIR:=$(ROOT)/specs

K_REPO_DIR:=$(abspath $(BUILD_DIR)/k)

K_BIN:=$(abspath $(K_REPO_DIR)/k-distribution/target/release/k/bin)

KPROVE:=$(K_BIN)/kprove -v --debug -d $(KEVM_REPO_DIR)/.build/defn/java -m VERIFICATION --z3-impl-timeout 500 \
        --deterministic-functions --no-exc-wrap \
        --cache-func-optimized --no-alpha-renaming --format-failures --boundary-cells k,pc \
        --log-cells k,output,statusCode,localMem,pc,gas,wordStack,callData,accounts,memoryUsed,\#pc,\#result \
        $(KPROVE_OPTS)

SPEC_FILES:=$(patsubst %,$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k,$(SPEC_NAMES))

PANDOC_TANGLE_SUBMODULE:=$(ROOT)/.build/pandoc-tangle
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

$(SPECS_DIR)/lemmas.k: $(RESOURCES)/lemmas.md $(TANGLER)
	pandoc --from markdown --to "$(TANGLER)" --metadata=code:".k" $< > $@

$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k: $(TMPLS) $(SPEC_INI)
	python3 $(RESOURCES)/gen-spec.py $(TMPLS) $(SPEC_INI) $* $* > $@

#
# Kprove
#

test: $(addsuffix .test,$(SPEC_FILES))

$(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k.test: $(SPECS_DIR)/$(SPEC_GROUP)/%-spec.k
	$(KPROVE) $<
