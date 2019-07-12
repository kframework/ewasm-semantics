EWasm specification
=================

```k
require "deps/wasm-semantics/wasm.k"
require "deps/eei-semantics/eei.k"

module EWASM
```

EWasm consists of a WebAssembly (Wasm) semantics, and an Ethereum Environment Interface (EEI) semantics, and rules to pass calls and data between them.

```k
    imports EEI
    imports WASM
```

The configuration composes both the top level cells of the Wasm and EEI semantics.

```k
    configuration
      <eei/>
      <wasm/>
```

Conventions
-----------

Instructions for calling into the EEI from Wasm are prefixed with *lowercase* `eei.`, e.g. `eei.getCaller`.
EEI methods are prefixed with *uppercase* `EEI`, e.g. `EEI.getCaller`.

Storing code in contracts
-------------------------

Make a wasm program storable in contract code.

```k
    syntax Code ::= ModuleDecl
 // --------------------------
```

Helper instructions
-------------------

The Wasm semantics will sometimes produce instructions for the EEI to execute, and then waits to consume the result.
The EEI produces results, and waits for instructions from the Wasm engine.
The Wasm engine needs to not make any further progress while waiting for the EEI.
The EEI signals end of execution by setting an appropriate status code.
The token `#waiting` dosen't have associated rules in either transition system, and so will only be processed by rules in this embedder.

```k
    syntax Instr ::= "#waiting" "(" EEIMethod ")"
 // ---------------------------------------------
```

Many instructions return a value, a certain number of bytes in length, that needs to be stored to Wasm linear memory.
The trapping conditions for these stores is the same as for regular Wasm stores.
The following function helps with this task.

```k
    syntax Instrs ::= #storeEeiResult(Int, Int, Int) [function]
 // -----------------------------------------------------------
    rule #storeEeiResult(STARTIDX, LENGTHBYTES, VALUE)
      => (i32.store8 (i32.const STARTIDX) (i32.const VALUE))
         #storeEeiResult(STARTIDX +Int 1, LENGTHBYTES -Int 1, VALUE /Int 256)
      requires LENGTHBYTES >Int 0
    rule #storeEeiResult(_, 0, _) => nop
```

Exceptional halting
-------------------

An exception in the EEI translates into a `trap` in Wasm.

```k
    rule <k> #waiting(_) => trap ... </k>
         <statusCode> STATUSCODE </statusCode>
      requires notBool isEndStatusCode(STATUSCODE)
```

EEI calls
---------

Load the caller address (20 bytes) into memory at the spcified location.

```k
    syntax PlainInstr ::= "eei.getCaller"
 // -------------------------------------
    rule <k> eei.getCaller => #waiting(EEI.getCaller) ... </k>
         <eeiK> . => EEI.getCaller ... </eeiK>

    rule <k> #waiting(EEI.getCaller) => #storeEeiResult(PTR, 20, ADDR) ... </k>
         <valstack> <i32> PTR : STACK => STACK </valstack>
         <eeiK> #result(ADDR) => . ... </eeiK>
```

```k
endmodule
```
