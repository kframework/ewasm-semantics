# Settings
# --------

BUILD_DIR := .build
DEPS_DIR  := deps
DEFN_DIR  := $(BUILD_DIR)/defn

KWASM_SUBMODULE := $(DEPS_DIR)/wasm-semantics
EEI_SUBMODULE   := $(DEPS_DIR)/eei-semantics
k_submodule     := $(KWASM_SUBMODULE)/deps/k

ifneq (,$(wildcard $(k_submodule)/k-distribution/target/release/k/bin/*))
    K_RELEASE ?= $(abspath $(k_submodule)/k-distribution/target/release/k)
else
    K_RELEASE ?= $(dir $(shell which kompile))..
endif
K_BIN := $(K_RELEASE)/bin
K_LIB := $(K_RELEASE)/lib/kframework
export K_RELEASE

PATH:=$(K_BIN):$(abspath $(KWASM_SUBMODULE)):$(PATH)
export PATH


KWASM_MAKE := make --directory $(KWASM_SUBMODULE) BUILD_DIR=../../$(BUILD_DIR) RELEASE=$(RELEASE)

.PHONY: all clean deps                  \
        build build-%                   \
        test test-execution test-simple \
        test-prove                      \
        media presentations reports

all: build

clean:
	rm -rf $(BUILD_DIR)
	git submodule update --init --recursive
	$(MAKE) clean -C $(KWASM_SUBMODULE)
	$(MAKE) clean -C $(EEI_SUBMODULE)

# Build Dependencies (K Submodule)
# --------------------------------

EEI_FILES:=eei.md
EEI_SOURCE_FILES:=$(patsubst %, $(EEI_SUBMODULE)/%, $(EEI_FILES))
EWASM_FILES:=ewasm-test.md driver.md ewasm.md kewasm-lemmas.md
EWASM_SOURCE_FILES:=$(EWASM_FILES)
EXTRA_FILES:=$(EEI_FILES) $(EWASM_FILES)
EXTRA_SOURCE_FILES:=$(patsubst %, $(KWASM_SUBMODULE)/%, $(EXTRA_FILES))

deps:
	$(KWASM_MAKE) deps

# Building Definition
# -------------------

MAIN_MODULE=EWASM-TEST
MAIN_SYNTAX_MODULE=EWASM-TEST-SYNTAX
MAIN_DEFN_FILE=ewasm-test

# Build definitions

KOMPILE_OPTS :=

build: build-llvm build-haskell

build-%: $(EXTRA_SOURCE_FILES)
	$(KWASM_MAKE) build-$*                           \
	    DEFN_DIR=../../$(DEFN_DIR)                   \
	    llvm_main_module=$(MAIN_MODULE)              \
	    llvm_syntax_module=$(MAIN_SYNTAX_MODULE)     \
	    llvm_main_file=$(MAIN_DEFN_FILE)             \
	    haskell_main_module=$(MAIN_MODULE)           \
	    haskell_syntax_module=$(MAIN_SYNTAX_MODULE)  \
	    haskell_main_file=$(MAIN_DEFN_FILE)          \
	    EXTRA_SOURCE_FILES="$(EXTRA_FILES)"          \
	    KOMPILE_OPTS="$(KOMPILE_OPTS)"

$(KWASM_SUBMODULE)/%.md: %.md
	cp $< $@

$(KWASM_SUBMODULE)/%.md: $(EEI_SUBMODULE)/%.md
	cp $< $@

# Testing
# -------

TEST_CONCRETE_BACKEND:=llvm
TEST_SYMBOLIC_BACKEND:=haskell
TEST:=./kewasm
KPROVE_MODULE:=KEWASM-LEMMAS
KPROVE_OPTS:=
CHECK:=git --no-pager diff --no-index --ignore-all-space

tests/%/make.timestamp:
	@echo "== submodule: $@"
	git submodule update --init -- tests/$*
	touch $@

test: test-execution test-prove

# Generic Test Harnesses

tests/%.debug: tests/%
	$(TEST) run --backend llvm $< --debugger

tests/%.run: tests/%
	$(TEST) run --backend $(TEST_CONCRETE_BACKEND) $< > tests/$*.$(TEST_CONCRETE_BACKEND)-out
	$(CHECK) tests/success-$(TEST_CONCRETE_BACKEND).out tests/$*.$(TEST_CONCRETE_BACKEND)-out
	rm -rf tests/$*.$(TEST_CONCRETE_BACKEND)-out

tests/%.parse: tests/%
	$(TEST) kast --backend $(TEST_CONCRETE_BACKEND) $< kast > $@-out
	$(CHECK) $@-expected $@-out
	rm -rf $@-out

tests/%.prove: tests/%
	$(TEST) prove --backend $(TEST_SYMBOLIC_BACKEND) $(filter --repl, $(KPROVE_OPTS)) $< --format-failures --def-module $(KPROVE_MODULE) $(filter-out --repl, $(KPROVE_OPTS))

### Execution Tests

test-execution: test-simple

simple_tests:=$(wildcard tests/simple/*.wast)

test-simple: $(simple_tests:=.run)

### Proof Tests

proof_tests:=$(wildcard tests/proofs/*-spec.k)
slow_proof_tests:=tests/proofs/loops-spec.k
quick_proof_tests:=$(filter-out $(slow_proof_tests), $(proof_tests))

test-prove: $(proof_tests:=.prove)

