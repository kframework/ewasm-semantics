EWASM specification
=================

```k
require "deps/wasm-semantics/test.k"
require "deps/eei-semantics/eei.k"

module EWASM
    imports EEI
    imports WASM-TEST
    
    configuration
      <ewasm>
        <eei/>
        <wasm/>
      </ewasm>
```

Make a wasm program storable in contract code.

```k
    syntax Code ::= Defns
```

Helper instructions
-------------------

The Wasm will sometimes produce instructions for the EEI to execute, and then waits to consume the result.
The EEI produces results, and waits for instructions from the Wasm engine.
The Wasm engine needs to not make any further progress while waiting for the EEI.
The EEI signals end of execution by setting an appropriate status code.
The token `#waiting` dosen't have associated rules in either transition system, and so will only be processed by rules in this embedder.

```k
    syntax Instr ::= "#waiting" "(" EEIMethod ")"
 // ---------------------------------------------
```


```k
```

EEI calls
---------

Load the caller address (20 bytes) into memory at the spcified location.

```k
    syntax PlainInstr ::= "eei.getCaller"
 // -------------------------------------
    rule <k> eei.getCaller => #waiting(EEI.getCaller) ... </k>
         <eeiK> . => EEI.getCaller </eeiK>

    rule <k> #waiting(EEI.getCaller PTR) => #storeEeiResult(PTR, 20, ADDR) ... </k>
         <valstack> <i32> PTR : STACK => STACK </valstack>
         <eeiK> #result(ADDR) </eeiK>
```

```k
endmodule
```
