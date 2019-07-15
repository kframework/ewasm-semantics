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
      <ewasm>
        <eei/>
        <wasm/>
        <paramstack> .ParamStack </paramstack>
      </ewasm>
```

Conventions
-----------

Instructions for calling into the EEI from Wasm are prefixed with *lowercase* `eei.`, e.g. `eei.getCaller`.
EEI methods are prefixed with *uppercase* `EEI`, e.g. `EEI.getCaller`.

Storing code in contracts
-------------------------

Make a wasm program storable in contract code.
The code will point to the module instance of the contract.

```k
    syntax Code ::= Int
 // -------------------
```

Extending the Wasm instruction set with host calls
--------------------------------------------------

```k
    syntax Instr ::= HostCall
 // -------------------------
```

Helper instructions
-------------------

Values which exceed 8 bytes are passed to EEI in the linear memory.
To abstract this common pattern, we use the `#gatherParams` instruction.
It takes a list of parameters to gather from memory, and pushes them to a separate stack of integers.

```k
    syntax ParamStack ::= List{Int, ":"}
 // ----------------------------------------
```

If any parameter causes an out-of-bounds access, a trap occurs.
After all parameters have been gathered on the stack, the continuation (as a `HostCall`) remains in the `#gatheredCall` instruction.
Each such call is handled differently, and so the rules for them are specified in their respective sections.

```k
    syntax MemoryVariable  ::= "(" Int "," Int ")"
    syntax MemoryVariables ::= List {MemoryVariable, ""}
 // ----------------------------------------------------

    syntax Instrs ::= "#gatherParams" "(" HostCall "," MemoryVariables ")"
 // --------------------------------------------------
    rule <k> #gatherParams(HC,            .MemoryVariables) => #gatheredCall(HC)     ... </k>
    rule <k> #gatherParams(HC, (IDX, LEN) MS              ) => #gatherParams(HC, MS) ... </k>
         <paramstack> PSTACK => #range(DATA , IDX, LEN) : PSTACK </paramstack>
         <curModIdx> CUR </curModIdx>
         <moduleInst>
           <modIdx> CUR </modIdx>
           <memAddrs> 0 |-> ADDR </memAddrs>
           ...
         </moduleInst>
         <memInst>
           <mAddr> ADDR </mAddr>
           <msize> SIZE </msize>
           <mdata> DATA </mdata>
           ...
         </memInst>
       requires IDX +Int LEN <Int SIZE *Int #pageSize()

    rule <k> #gatherParams(HC, (IDX, LEN) MS) => trap ... </k>
         <curModIdx> CUR </curModIdx>
         <moduleInst>
           <modIdx> CUR </modIdx>
           <memAddrs> 0 |-> ADDR </memAddrs>
           ...
         </moduleInst>
         <memInst>
           <mAddr> ADDR </mAddr>
           <msize> SIZE </msize>
           ...
         </memInst>
       requires IDX +Int LEN >=Int SIZE *Int #pageSize()

    syntax Instr  ::= "#gatheredCall" "(" HostCall ")"
 // --------------------------------------------------
```

The Wasm semantics will sometimes produce instructions for the EEI to execute, and then waits to consume the result.
The EEI produces results, and waits for instructions from the Wasm engine.
The Wasm engine needs to not make any further progress while waiting for the EEI.
The EEI signals end of execution by setting an appropriate status code.
The token `#waiting` dosen't have associated rules in either transition system, and so will only be processed by rules in this embedder.

```k
    syntax Instr ::= "#waiting" "(" HostCall ")"
 // --------------------------------------------
```

Many instructions return a value, a certain number of bytes in length, that needs to be stored to Wasm linear memory.
The trapping conditions for these stores is the same as for regular Wasm stores.
The following function helps with this task.
All data that gets passed is a number of bytes divisible by 4, the same number of bytes as an i32, so storage will happen in increments of 4 bytes.

```k
    syntax Instrs ::= #storeEeiResult(Int, Int, Int) [function]
 // -----------------------------------------------------------
    rule #storeEeiResult(STARTIDX, LENGTHBYTES, VALUE)
      => (i32.store (i32.const STARTIDX) (i32.const VALUE))
         #storeEeiResult(STARTIDX +Int 4, LENGTHBYTES -Int 4, VALUE /Int #pow(i32))
      requires LENGTHBYTES >Int 0
    rule #storeEeiResult(_, 0, _) => .Instrs
```

Exceptional halting
-------------------

An exception in the EEI translates into a `trap` in Wasm.

```k
    rule <k> #waiting(_) => trap ... </k>
         <eeiK> . </eeiK>
         <statusCode> STATUSCODE </statusCode>
      requires notBool (STATUSCODE ==K .StatusCode
                 orBool isEndStatusCode(STATUSCODE)
                       )
```

The "ethereum" host module
--------------------------

The "ethereum" module is a module of host functions.
It doesn't exist as a Wasm modules, so we need to treat it specially.
An Ewasm contract interacts with the "ethereum" host module by importing its functions.

```k
    rule <k> ( import "ethereum" FNAME (func OID:OptionalId TUSE:TypeUse) )
          => ( func OID TUSE .LocalDecls #eeiFunction(FNAME) .Instrs )
         ...
         </k>

    syntax Instr ::= #eeiFunction(String) [function]
 // ------------------------------------------------
    rule #eeiFunction("getCaller")    => eei.getCaller
    rule #eeiFunction("storageStore") => eei.storageStore
```

EEI calls
---------

### Call state methods

#### `getCaller`

Load the caller address (20 bytes) into memory at the spcified location.

```k
    syntax HostCall ::= "eei.getCaller"
 // -----------------------------------
    rule <k> eei.getCaller => #waiting(eei.getCaller) ... </k>
         <eeiK> . => EEI.getCaller ... </eeiK>

    rule <k> #waiting(eei.getCaller) => #storeEeiResult(PTR, 20, ADDR) ... </k>
         <locals> 0 |-> <i32> PTR </locals>
         <eeiK> #result(ADDR) => . ... </eeiK>
```

### World state methods

#### `storageStore`

In the executing account's storage, store the 32 bytes at `VALUEPTR` in linear memory to the storage location specified by the 32 bytes at `INDEXPTR` in linear memory.

```k
    syntax HostCall ::= "eei.storageStore"
 // --------------------------------------
    rule <k> eei.storageStore => #gatherParams(eei.storageStore, (INDEXPTR, 32) (VALUEPTR, 32)) ... </k>
         <locals>
           0 |-> <i32> INDEXPTR
           1 |-> <i32> VALUEPTR
         </locals>

    rule <k> #gatheredCall(eei.storageStore) => #waiting(eei.storageStore) ... </k>
         <paramstack> VALUE : INDEX : .ParamStack => .ParamStack </paramstack>
         <eeiK> . => EEI.setAccountStorage INDEX VALUE ... </eeiK>

    rule <k> #waiting(eei.storageStore) => . ... </k>
         <statusCode> EVM_SUCCESS </statusCode>
```

```k
endmodule
```
