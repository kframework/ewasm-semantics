# Settings
# --------

deps_dir        := deps
KWASM_SUBMODULE := $(deps_dir)/wasm-semantics
eei_submodule   := $(deps_dir)/eei-semantics
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

build_dir         := .build
DEFN_DIR          := $(build_dir)/defn
kompiled_dir_name := ewasm-test

KWASM_MAKE := make --directory $(KWASM_SUBMODULE) BUILD_DIR=../../$(BUILD_DIR) RELEASE=$(RELEASE)
eei_make   := make --directory $(eei_submodule)   DEFN_DIR=../../$(DEFN_DIR)

pandoc_tangle_submodule := $(KWASM_SUBMODULE)/deps/pandoc-tangle
tangler                 := $(pandoc_tangle_submodule)/tangle.lua
LUA_PATH                := $(pandoc_tangle_submodule)/?.lua;;
export LUA_PATH

.PHONY: all clean \
        deps haskell-deps \
        defn defn-llvm defn-haskell \
        definition-deps wasm-definitions eei-definitions \
        build \
        test test-execution test-simple test-prove \
        media presentations reports

all: build

clean:
	rm -rf $(build_dir)
	rm -f $(KWASM_SUBMODULE)/make.timestamp
	rm -f $(eei_submodule)/make.timestamp
	git submodule update --init --recursive
	$(MAKE) clean -C $(KWASM_SUBMODULE)
	$(MAKE) clean -C $(eei_submodule)

# Build Dependencies (K Submodule)
# --------------------------------

wasm_files=test.md wasm.md wasm-text.md data.md kwasm-lemmas.md
wasm_source_files:=$(patsubst %, $(KWASM_SUBMODULE)/%, $(wasm_files))
eei_files:=eei.md
eei_source_files:=$(patsubst %, $(eei_submodule)/%, $(eei_files))
ewasm_files:=ewasm-test.md driver.md ewasm.md kewasm-lemmas.md
ewasm_source_files:=$(ewasm_files)
all_k_files:=$(ewasm_files) $(wasm_files) $(eei_files)

llvm_dir:=$(DEFN_DIR)/llvm
llvm_defn:=$(patsubst %, $(llvm_dir)/%, $(all_k_files))

haskell_dir:=$(DEFN_DIR)/haskell
haskell_defn:=$(patsubst %, $(haskell_dir)/%, $(all_k_files))

definition-deps: eei-definitions
deps: $(KWASM_SUBMODULE)/make.timestamp $(eei_submodule)/make.timestamp definition-deps

wasm-definitions:
	$(KWASM_MAKE) -B defn-llvm
	$(KWASM_MAKE) -B defn-haskell

eei-definitions: $(eei_source_files)
	$(eei_make) -B defn-llvm
	$(eei_make) -B defn-haskell

$(KWASM_SUBMODULE)/make.timestamp: $(wasm_source_files)
	$(KWASM_MAKE) deps
	touch $(KWASM_SUBMODULE)/make.timestamp

$(eei_submodule)/make.timestamp: $(eei_source_files)
	touch $(eei_submodule)/make.timestamp

# Building Definition
# -------------------

MAIN_MODULE=EWASM-TEST
MAIN_SYNTAX_MODULE=EWASM-TEST-SYNTAX
MAIN_DEFN_FILE=ewasm-test

# Build definitions

KOMPILE_OPTS :=

build: build-llvm build-haskell

build-%:
	cp $(eei_source_files) $(ewasm_source_files) $(KWASM_SUBMODULE)
	$(KWASM_MAKE) build-$*                               \
	    DEFN_DIR=../../$(DEFN_DIR)                       \
	    llvm_main_module=$(MAIN_MODULE)                  \
	    llvm_syntax_module=$(MAIN_SYNTAX_MODULE)         \
	    llvm_main_file=$(MAIN_DEFN_FILE)                 \
	    haskell_main_module=$(MAIN_MODULE)               \
	    haskell_syntax_module=$(MAIN_SYNTAX_MODULE)      \
	    haskell_main_file=$(MAIN_DEFN_FILE)              \
	    EXTRA_SOURCE_FILES="$(eei_files) $(ewasm_files)"        \
	    KOMPILE_OPTS="$(KOMPILE_OPTS)"

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

