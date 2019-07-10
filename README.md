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
Wasm code is executed by the Wasm semantics, and calls to the Ethereum environment are executed by the EEI semantics.
The file `ewasm.md` contains the semantics which handles passing data between the two execution engines.
