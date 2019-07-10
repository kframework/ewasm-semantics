# Settings
# --------

build_dir:=.build
deps_dir:=deps
defn_dir:=$(build_dir)/defn
k_submodule:=$(deps_dir)/k
pandoc_tangle_submodule:=$(deps_dir)/pandoc-tangle
k_bin:=$(k_submodule)/k-distribution/target/release/k/bin
tangler:=$(pandoc_tangle_submodule)/tangle.lua
wasm_submodule:=$(deps_dir)/wasm-semantics
eei_submodule:=$(deps_dir)/eei-semantics

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
	git submodule update --init --recursive

# Build Dependencies (K Submodule)
# --------------------------------

deps: $(k_submodule)/make.timestamp $(pandoc_tangle_submodule)/make.timestamp ocaml-deps definition-deps

$(k_submodule)/make.timestamp:
	git submodule update --init --recursive
	cd $(k_submodule) && mvn package -DskipTests -Dllvm.backend.skip
	touch $(k_submodule)/make.timestamp

$(pandoc_tangle_submodule)/make.timestamp:
	git submodule update --init -- $(pandoc_tangle_submodule)
	touch $(pandoc_tangle_submodule)/make.timestamp

ocaml-deps:
	eval $$(opam config env) \
	    opam install --yes mlgmp zarith uuidm

# Building Definition
# -------------------

wasm_files:=$(patsubst %, $(wasm_submodule)/%, test.k wasm.k data.k)
eei_files:=$(eei_submodule)/eei.k
ewasm_files:=ewasm.k $(wasm_files) $(eei_files)

ocaml_dir:=$(defn_dir)/ocaml
ocaml_defn:=$(patsubst %, $(ocaml_dir)/%, $(ewasm_files))
ocaml_kompiled:=$(ocaml_dir)/ewasm-kompiled/interpreter

java_dir:=$(defn_dir)/java
java_defn:=$(patsubst %, $(java_dir)/%, $(ewasm_files))
java_kompiled:=$(java_dir)/ewasm-kompiled/compiled.txt

haskell_dir:=$(defn_dir)/haskell
haskell_defn:=$(patsubst %, $(haskell_dir)/%, $(ewasm_files))
haskell_kompiled:=$(haskell_dir)/ewasm-kompiled/definition.kore

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
	eval $$(opam config env)                                 \
	    $(k_bin)/kompile -O3 --non-strict --backend ocaml    \
	    --directory $(ocaml_dir) -I $(ocaml_dir)             \
	    --main-module EWASM --syntax-module EWASM $<

$(java_kompiled): $(java_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend java                          \
	    --directory $(java_dir) -I $(java_dir)               \
	    --main-module EWASM --syntax-module EWASM $<

$(haskell_kompiled): $(haskell_defn)
	@echo "== kompile: $@"
	$(k_bin)/kompile --backend haskell                       \
	    --directory $(haskell_dir) -I $(haskell_dir)         \
	    --main-module EWASM --syntax-module EWASM $<
