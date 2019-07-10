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
The EEI needs to signal when a result is done.
The tokens `#waiting` and `#done` don't have associated rules in either transition system, and so will only be processed by rules in this embedder


```k
    syntax Instr     ::= "#waiting"
    syntax EEIMethod ::= "#done"
 // ----------------------------
```

```k
    syntax Intr ::= "eei.getCaller"
 // -------------------------------
    rule <k> eei.getCaller => #waiting ... </k>
         <eeiK> . => EEI.getCaller </eeiK>

```

```k
endmodule
```
