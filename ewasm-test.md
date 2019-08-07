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

Grouping sorts.

```k
    syntax EthereumCommand ::= Assertion | Action
 // ---------------------------------------------
```

```k
    syntax Action ::= "#clearEwasmConfig"
 // -------------------------------------
    rule <k> #clearEwasmConfig => #clearConfig ... </k>
         <eeiK> . => EEI.clearConfig ... </eeiK>
         <ewasmLog> _ => "" </ewasmLog>
```

Assertions
----------

```k
    syntax Assertion ::= "#assertReturnData" CallData WasmString
 // ------------------------------------------------------------
    rule <k> #assertReturnData DATA MSG => . ... </k>
         <returnData> BYTES </returnData>
      requires CallData2Bytes(DATA) ==K BYTES
```

```k
endmodule
```
