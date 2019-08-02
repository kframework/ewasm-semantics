Testing
=======

We make use of the testing module for Wasm, which will let us make assertions about the Wasm runtime state.

```k
requires "test.k" // WASM-TEST
requires "driver.k"

module EWASM-TEST-SYNTAX
   imports WASM-TEST-SYNTAX
   imports EWASM-TEST
endmodule
```

```k
module EWASM-TEST
  imports WASM-TEST
  imports DRIVER
```

```k
    syntax Action ::= "#clearEwasmConfig"
 // -------------------------------------
    rule <k> #clearEwasmConfig => #clearConfig ... </k>
         <eeiK> . => EEI.clearConfig ... </eeiK>
```

Assertions
----------

```// TODO:reintroduce
    syntax Assertion ::= "#assertCallData" CallData WasmString
 // ----------------------------------------------------------
    rule <k> #assertCallData CALLDATA MSG => . ... </k>
         <callData> CALLDATA' </callData>
      requires CallData2Bytes(CALLDATA) ==K CALLDATA'
```

```k
endmodule
```
