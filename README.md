K Semantics of eWasm
====================

**Under Construction**

Prototype semantics of [EWasm](https://github.com/ewasm/design) in the K framework.

```
git submodule update --init --recursive
make deps
make build
```

# Structure

This project makes use of the K framework [EEI](https://github.com/kframework/eei-semantics) and [Wasm](https://github.com/kframework/wasm-semantics) semantics.
The main file is `ewasm.md`, which specifies the embedder that acts as a bridge between the Wasm semantics and the EEI.

# Contract interface

EWasm is a subset of [WebAssembly](https://github.com/WebAssembly/spec) (Wasm).
Wasm does not specify how modules are embedded, how functions are invoked from the embedder, etc.
EWasm specifies a [contract interface](https://github.com/ewasm/design/blob/master/contract_interface.md) (subject to change until finalized) all contracts must adhere to.

## Exports

A contract exports exactly one function, `"main"`, and a memory, `"memory"`.

## Data passing

From the Wasm point of view, data is passed either as parameters and return values, or (for larger data/data of unknonw size) through the linear memory.
