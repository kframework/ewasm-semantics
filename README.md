# This project has been archived (2023-03-23)

See [KWasm](https://github.com/runtimeverification/wasm-semantics) for the core semantics of WebAssembly.
At this time (2023-03-23) it is being used for [Elrond/MetaverseX semantics](https://github.com/runtimeverification/elrond-semantics).

---

K Semantics of Ewasm
====================

**Under Construction**

Prototype semantics of [Ewasm](https://github.com/ewasm/design) in the K framework.

```sh
git submodule update --init --recursive
make deps
make build
```

# Proving

Run existing proofs using `make` rules.

```sh
make tests/proofs/example-spec.k.prove
make tests/proofs/example-spec.k.repl
```

You can run the prover on your own specification, with a lemmas module of your choice.

```sh
./kewasm prove <path>/<to>/<spec> -m <LEMMAS-MODULE>  # Runs the prover on the given spec, using LEMMAS-MODULE as the top-level sematics module.
```

You can add the `--repl` flag to run the proof in an interactive REPL, where you can step through the proof and explore its branches.

```sh
./kewasm prove <path>/<to>/<spec> -m <LEMMAS-MODULE>  # Runs the prover on the given spec, using LEMMAS-MODULE as the top-level sematics module.
```

# Structure

This project makes use of the K framework [EEI](https://github.com/kframework/eei-semantics) and [Wasm](https://github.com/kframework/wasm-semantics) semantics.
The main file is `ewasm.md`, which specifies the embedder that acts as a bridge between the Wasm semantics and the EEI.

# Contract interface

Ewasm is a subset of [WebAssembly](https://github.com/WebAssembly/spec) (Wasm).
Wasm does not specify how modules are embedded, how functions are invoked from the embedder, etc.
Ewasm specifies a [contract interface](https://github.com/ewasm/design/blob/master/contract_interface.md) (subject to change until finalized) all contracts must adhere to.

## Exports

A contract exports exactly one function, `"main"`, and a memory, `"memory"`.

## Data passing

From the Wasm point of view, data is passed either as parameters and return values, or (for larger data/data of unknonw size) through the linear memory.
