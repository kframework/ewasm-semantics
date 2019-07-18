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
wasm_make:=make --directory $(wasm_submodule) defn_dir=../../$(defn_dir)
wasm_clean:=make --directory $(wasm_submodule) clean
eei_make:=make --directory $(eei_submodule) DEFN_DIR=../../$(defn_dir)
eei_clean:=make --directory $(eei_submodule) clean

LUA_PATH=$(pandoc_tangle_submodule)/?.lua;;
export LUA_PATH

.PHONY: all clean \
        deps ocaml-deps haskell-deps \
        defn defn-ocaml defn-java defn-haskell \
        build build-ocaml defn-haskell build-haskell \
        test test-execution test-simple test-prove test-klab-prove \
        media presentations reports definition-deps

all: build

clean:
	rm -rf $(build_dir)
	rm -f $(wasm_submodule)/make.timestamp
	rm -f $(eei_submodule)/make.timestamp
	git submodule update --init --recursive

# Build Dependencies (K Submodule)
# --------------------------------

deps: $(wasm_submodule)/make.timestamp $(eei_submodule)/make.timestamp ocaml-deps definition-deps

$(wasm_submodule)/make.timestamp:
	git submodule update --init --recursive
	$(wasm_make) deps
	$(wasm_make) defn-java
	$(wasm_make) defn-ocaml
	$(wasm_make) defn-haskell
	touch $(wasm_submodule)/make.timestamp

$(eei_submodule)/make.timestamp:
	git submodule update --init --recursive
	$(eei_make) defn-java
	$(eei_make) defn-ocaml
	$(eei_make) defn-haskell
	touch $(eei_submodule)/make.timestamp

ocaml-deps:
	eval $$(opam config env) \
	    opam install --yes mlgmp zarith uuidm

# Building Definition
# -------------------

wasm_files:=$(patsubst %, $(wasm_submodule)/%, test.k wasm.k data.k)
eei_files:=$(eei_submodule)/eei.k
ewasm_files:=ewasm-test.k driver.k ewasm.k

ocaml_dir:=$(defn_dir)/ocaml
ocaml_defn:=$(patsubst %, $(ocaml_dir)/%, $(ewasm_files))
ocaml_kompiled:=$(ocaml_dir)/test-kompiled/interpreter

java_dir:=$(defn_dir)/java
java_defn:=$(patsubst %, $(java_dir)/%, $(ewasm_files))
java_kompiled:=$(java_dir)/test-kompiled/compiled.txt

haskell_dir:=$(defn_dir)/haskell
haskell_defn:=$(patsubst %, $(haskell_dir)/%, $(ewasm_files))
haskell_kompiled:=$(haskell_dir)/test-kompiled/definition.kore

# Tangle definition from *.md files

defn: defn-ocaml defn-java defn-haskell
defn-ocaml: $(ocaml_defn)
defn-java: $(java_defn)
defn-haskell: $(haskell_defn)

$(ocaml_dir)/%.k: %.md $(pandoc_tangle_submodule)/make.timestamp
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to $(tangler) --metadata=code:.k $< > $@

$(java_dir)/%.k: %.md $(pandoc_tangle_submodule)/make.timestamp
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to $(tangler) --metadata=code:.k $< > $@

$(haskell_dir)/%.k: %.md $(pandoc_tangle_submodule)/make.timestamp
	@echo "==  tangle: $@"
	mkdir -p $(dir $@)
	pandoc --from markdown --to $(tangler) --metadata=code:.k $< > $@

# Build definitions

build: build-ocaml build-java build-haskell
build-ocaml: $(ocaml_kompiled)
build-java: $(java_kompiled)
build-haskell: $(haskell_kompiled)

$(ocaml_kompiled): $(ocaml_defn)
	@echo "== kompile: $@"
	eval $$(opam config env)                              \
	    $(k_bin)/kompile -O3 --non-strict --backend ocaml \
	    --directory $(ocaml_dir) -I $(ocaml_dir)          \
	    --main-module   EWASM-TEST               \
      --syntax-module EWASM-TEST $<

$(java_kompiled): $(java_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend java            \
	    --directory $(java_dir) -I $(java_dir) \
	    --main-module   EWASM-TEST    \
      --syntax-module EWASM-TEST $<

$(haskell_kompiled): $(haskell_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend haskell               \
	    --directory $(haskell_dir) -I $(haskell_dir) \
	    --main-module   EWASM-TEST          \
      --syntax-module EWASM-TEST $<

# Testing
# -------

TEST_CONCRETE_BACKEND:=ocaml
TEST_SYMBOLIC_BACKEND:=java
TEST:=./kewasm
KPROVE_MODULE:=KWASM-LEMMAS
CHECK:=git --no-pager diff --no-index --ignore-all-space

tests/%/make.timestamp:
	@echo "== submodule: $@"
	git submodule update --init -- tests/$*
	touch $@

test: test-execution test-prove

# Generic Test Harnesses

tests/%.run: tests/%
	$(TEST) run --backend $(TEST_CONCRETE_BACKEND) $< > tests/$*.$(TEST_CONCRETE_BACKEND)-out
	$(CHECK) tests/success-$(TEST_CONCRETE_BACKEND).out tests/$*.$(TEST_CONCRETE_BACKEND)-out
	rm -rf tests/$*.$(TEST_CONCRETE_BACKEND)-out

tests/%.parse: tests/%
	$(TEST) kast --backend $(TEST_CONCRETE_BACKEND) $< kast > $@-out
	$(CHECK) $@-expected $@-out
	rm -rf $@-out

tests/%.prove: tests/%
	$(TEST) prove --backend $(TEST_SYMBOLIC_BACKEND) $< --format-failures --def-module $(KPROVE_MODULE)

tests/%.klab-prove: tests/%
	$(TEST) klab-prove --backend $(TEST_SYMBOLIC_BACKEND) $< --format-failures --def-module $(KPROVE_MODULE)

### Execution Tests

test-execution: test-simple

simple_tests:=$(wildcard tests/simple/*.wast)

test-simple: $(simple_tests:=.run)

### Proof Tests

proof_tests:=$(wildcard tests/proofs/*-spec.k)
slow_proof_tests:=tests/proofs/loops-spec.k
quick_proof_tests:=$(filter-out $(slow_proof_tests), $(proof_tests))

test-prove: $(proof_tests:=.prove)

### KLab interactive

test-klab-prove: $(quick_proof_tests:=.klab-prove)
