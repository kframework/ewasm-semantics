# Settings
# --------

deps_dir:=deps
wasm_submodule:=$(deps_dir)/wasm-semantics
eei_submodule:=$(deps_dir)/eei-semantics
k_submodule:=$(wasm_submodule)/deps/k
pandoc_tangle_submodule:=$(wasm_submodule)/deps/pandoc-tangle
k_bin:=$(k_submodule)/k-distribution/target/release/k/bin
tangler:=$(pandoc_tangle_submodule)/tangle.lua
build_dir:=.build
defn_dir:=$(build_dir)/defn
kompiled_dir_name:=ewasm-test
wasm_make:=make --directory $(wasm_submodule) DEFN_DIR=../../$(defn_dir)
wasm_clean:=make --directory $(wasm_submodule) clean
eei_make:=make --directory $(eei_submodule) DEFN_DIR=../../$(defn_dir)
eei_clean:=make --directory $(eei_submodule) clean

LUA_PATH=$(pandoc_tangle_submodule)/?.lua;;
export LUA_PATH

.PHONY: all clean \
        deps haskell-deps \
        defn defn-llvm defn-haskell \
        definition-deps wasm-definitions eei-definitions \
        build build-llvm build-haskell \
        test test-execution test-simple test-prove \
        media presentations reports

all: build

clean:
	rm -rf $(build_dir)
	rm -f $(wasm_submodule)/make.timestamp
	rm -f $(eei_submodule)/make.timestamp
	git submodule update --init --recursive
	$(MAKE) clean -C $(wasm_submodule)
	$(MAKE) clean -C $(eei_submodule)

# Build Dependencies (K Submodule)
# --------------------------------

wasm_files=test.k wasm.k data.k kwasm-lemmas.k
wasm_source_files:=$(patsubst %, $(wasm_submodule)/%, $(patsubst %.k, %.md, $(wasm_files)))
eei_files:=eei.k
eei_source_files:=$(patsubst %, $(eei_submodule)/%, $(patsubst %.k, %.md, $(eei_files)))
ewasm_files:=ewasm-test.k driver.k ewasm.k kewasm-lemmas.k
all_k_files:=$(ewasm_files) $(wasm_files) $(eei_files)

deps: $(wasm_submodule)/make.timestamp $(eei_submodule)/make.timestamp definition-deps

definition-deps: wasm-definitions eei-definitions

wasm-definitions:
	$(wasm_make) -B defn-llvm
	$(wasm_make) -B defn-haskell

eei-definitions: $(eei_source_files)
	$(eei_make) -B defn-llvm
	$(eei_make) -B defn-haskell

$(wasm_submodule)/make.timestamp: $(wasm_source_files)
	git submodule update --init --recursive
	$(wasm_make) deps
	touch $(wasm_submodule)/make.timestamp

$(eei_submodule)/make.timestamp: $(eei_source_files)
	git submodule update --init --recursive
	touch $(eei_submodule)/make.timestamp

# Building Definition
# -------------------

llvm_dir:=$(defn_dir)/llvm
llvm_defn:=$(patsubst %, $(llvm_dir)/%, $(all_k_files))
llvm_kompiled:=$(llvm_dir)/ewasm-test-kompiled/interpreter

haskell_dir:=$(defn_dir)/haskell
haskell_defn:=$(patsubst %, $(haskell_dir)/%, $(all_k_files))
haskell_kompiled:=$(haskell_dir)/ewasm-test-kompiled/definition.kore

main_module=EWASM-TEST
syntax_module=EWASM-TEST-SYNTAX

# Tangle definition from *.md files

defn: defn-llvm defn-haskell
defn-llvm: $(llvm_defn)
defn-haskell: $(haskell_defn)

$(llvm_dir)/%.k: %.md $(tangler)
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to $(tangler) --metadata=code:.k $< > $@

$(haskell_dir)/%.k: %.md $(tangler)
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to $(tangler) --metadata=code:.k $< > $@

# Build definitions

KOMPILE_OPTS :=

build: build-llvm build-haskell
build-llvm: $(llvm_kompiled)
build-haskell: $(haskell_kompiled)

$(llvm_kompiled): $(llvm_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend llvm            \
	    --directory $(llvm_dir) -I $(llvm_dir) \
	    --main-module $(main_module)           \
	    --syntax-module $(syntax_module) $<    \
	    $(KOMPILE_OPTS)

$(haskell_kompiled): $(haskell_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend haskell               \
	    --directory $(haskell_dir) -I $(haskell_dir) \
	    --main-module   $(main_module)               \
	    --syntax-module $(syntax_module) $<          \
	    $(KOMPILE_OPTS)

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

