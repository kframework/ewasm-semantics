Testing
=======

We make use of the testing module for Wasm, which will let us make assertions about the Wasm runtime state.

```k
requires "test.k" // WASM-TEST
requires "driver.k"

module EWASM-TEST
  imports WASM-TEST
  imports ETHEREUM-SIMULATION
```

```k
    syntax Action ::= "#clearEwasmConfig"
 // -------------------------------------
    rule <k> #clearEwasmConfig => #clearConfig ... </k>
         <eeiK> . => EEI.clearConfig ... </eeiK>
```

```k
endmodule
```
