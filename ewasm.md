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

*TODO*: The call pattern of taking a ceratin number of bytes of memory, making it an int and giving it as a parameter to the EEI is extremely common. Can we abstract it somehow?

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

In the executing account's storage, store the 32 bytes at `VALUEPTR` to the storage location specified by the 32 bytes at `INDEXPTR`.

```k
    syntax HostCall ::= "eei.storageStore"
 // --------------------------------------
    rule <k> eei.storageStore => #waiting(eei.storageStore) ... </k>
         <locals>
           0 |-> <i32> INDEXPTR
           1 |-> <i32> VALUEPTR
         </locals>
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
         <eeiK> . => EEI.setAccountStorage #range(DATA, INDEXPTR, 32) #range(DATA, VALUEPTR, 32) ... </eeiK>
       requires INDEXPTR +Int 32 <Int SIZE *Int #pageSize()
        andBool VALUEPTR +Int 32 <Int SIZE *Int #pageSize()

    rule <k> eei.storageStore => trap ... </k>
         <locals>
           0 |-> <i32> INDEXPTR
           1 |-> <i32> VALUEPTR
         </locals>
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
       requires INDEXPTR +Int 32 >=Int SIZE *Int #pageSize()
         orBool VALUEPTR +Int 32 >=Int SIZE *Int #pageSize()

    rule <k> #waiting(eei.storageStore) => . ... </k>
         <statusCode> STATUSCODE </statusCode>
      requires isEndStatusCode(STATUSCODE)
```

```k
endmodule
```
