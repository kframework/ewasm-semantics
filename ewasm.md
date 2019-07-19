Ewasm Specification
=================

```k
require "wasm.k"
require "eei.k"

module EWASM
```

Ewasm consists of a WebAssembly (Wasm) semantics, and an Ethereum Environment Interface (EEI) semantics, and rules to pass calls and data between them.

```k
    imports EEI
    imports WASM
    imports BYTES
    imports LIST
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

Storing Code in Contracts
-------------------------

We want to make a Wasm program storable in contract code.
We do this by extending the `Code` production with a Wasm module representation.
We do this through an indirection, by letting the code in a contract be a pointer into the store of modules.

```k
    syntax Code ::= Int
 // -------------------
```

Extending the Wasm Instruction Set With Host Calls
--------------------------------------------------

We encode host calls into the EEI by a set of special instructions.

```k
    syntax Instr ::= HostCall
 // -------------------------
```

### The "ethereum" Host Module

The "ethereum" module is a module of host functions.
It doesn't exist as a Wasm module, so we need to treat it specially.
An Ewasm contract interacts with the "ethereum" host module by importing its functions.
The host module functions consist of a single `HostCall` instruction.
When calling such a function, parameters are made into local variables as usual, and results need to be returned on the stack, as usual.
Then, when a `HostCall` instruction is encountered, parameters are gathered from memory and local variables, the EEI is invoked, and the Wasm execution waits for the EEI execution to finish.

```k
    rule <k> ( import "ethereum" FNAME (func OID:OptionalId TUSE:TypeUse) )
          => ( func OID TUSE .LocalDecls #eeiFunction(FNAME) .Instrs )
         ...
         </k>

    syntax Instr ::= #eeiFunction(String) [function]
 // ------------------------------------------------
    rule #eeiFunction("getCaller")     => eei.getCaller
    rule #eeiFunction("storageStore")  => eei.storageStore
    rule #eeiFunction("storageLoad")   => eei.storageLoad
    rule #eeiFunction("callDataCopy")  => eei.callDataCopy
```

### Helper Methods

Values which exceed 8 bytes are passed to EEI in the linear memory.
To abstract this common pattern, we use the `#gatherParams` instruction.
It takes a list of parameters to gather from memory, and pushes them to a separate stack of integers.

If any parameter causes an out-of-bounds access, a trap occurs.
After all parameters have been gathered on the stack, the continuation (as a `HostCall`) remains in the `#gatheredCall` instruction.
From the `#gatheredCall`, the parameters on the stack can be consumed and passed to the EEI.
`#gatherParams` takes `MemoryVariables`, which is a list of memory offsets and number of bytes, specifying from where to load the appropriate integer value.

```k
    syntax ParamStack ::= List{Int, ":"}
 // ----------------------------------------

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

Just like many host calls requires passing parameters in memory, many host calls return a value in Wasm linear memory.
The trapping conditions for these stores is the same as for regular Wasm stores.
The following function helps with this task.
All byte values in Ewasm are a number of bytes divisible by 4, the same number of bytes as an i32, so storage will happen in increments of 4 bytes.

```k
    syntax Instrs ::= #storeEeiResult(Int, Int, Int) [function]
                    | #storeEeiResult(Int, Bytes)    [function, klabel(storeEeiResultsBytes)]
 // -----------------------------------------------------------
    rule #storeEeiResult(STARTIDX, LENGTHBYTES, VALUE)
      => (i32.store (i32.const STARTIDX) (i32.const VALUE))
         #storeEeiResult(STARTIDX +Int 4, LENGTHBYTES -Int 4, VALUE /Int #pow(i32))
      requires LENGTHBYTES >Int 0
    rule #storeEeiResult(_, 0, _) => .Instrs

    rule #storeEeiResult(STARTIDX, BS:Bytes)
      => #storeEeiResult(STARTIDX, lengthBytes(BS), Bytes2Int(BS, LE, Unsigned))
```

The Wasm engine needs to not make any further progress while waiting for the EEI, since they are not meant to execute concurrently.
The `#waiting` means Wasm is waiting for the EEI, and when the EEI has completed its execution, Wasm can consume the result and proceed.

```k
    syntax Instr ::= "#waiting" "(" HostCall ")"
 // --------------------------------------------
```

Exceptional Halting
-------------------

An exception in the EEI translates into a `trap` in Wasm.

```k
    rule <k> #waiting(_) => trap ... </k>
         <eeiK> . </eeiK>
         <statusCode> STATUSCODE </statusCode>
      requires notBool (STATUSCODE ==K EVMC_SUCCESS)
```

`HostCall`s
-----------

### Call State Methods

#### `getCaller`

Load the caller address (20 bytes) into memory at the spcified location.

```k
    syntax HostCall ::= "eei.getCaller"
 // -----------------------------------
    rule <k> eei.getCaller => #waiting(eei.getCaller) ... </k>
         <eeiK> . => EEI.getCaller </eeiK>

    rule <k> #waiting(eei.getCaller) => #storeEeiResult(RESULTPTR, 20, ADDR) ... </k>
         <locals> 0 |-> <i32> RESULTPTR </locals>
         <eeiK> #result(ADDR) => . </eeiK>
         <statusCode> EVM_SUCCESS </statusCode>
```

### `callDataCopy`

Copy a number of bytes (`LENGTH`) from an offset (`DATAOFFSET`) from the bytes in the call data into a location in memory (`RESULTPTR`).
Traps if `DATAOFFSET` + `LENGTH` exceeds the length of the call data.

```k
    syntax HostCall ::= "eei.callDataCopy"
 // -------------------------------------
    rule <k> eei.callDataCopy => #waiting(eei.callDataCopy) ... </k>
         <eeiK> . => EEI.getCallData </eeiK>

    rule <k> #waiting(eei.callDataCopy) => #storeEeiResult(RESULTPTR, substrBytes(CALLDATA, DATAOFFSET, DATAOFFSET +Int LENGTH)) ... </k>
         <locals>
           0 |-> <i32> RESULTPTR
           1 |-> <i32> DATAOFFSET
           2 |-> <i32> LENGTH
         </locals>
         <eeiK> #result(CALLDATA:Bytes) => . </eeiK>
      requires DATAOFFSET +Int LENGTH <Int lengthBytes(CALLDATA)

    rule <k> #waiting(eei.callDataCopy) => trap ... </k>
         <locals>
           0 |-> <i32> _
           1 |-> <i32> DATAOFFSET
           2 |-> <i32> LENGTH
         </locals>
         <eeiK> #result(CALLDATA:Bytes) => . </eeiK>
      requires DATAOFFSET +Int LENGTH >=Int lengthBytes(CALLDATA)
```

### World State Methods

#### `storageLoad`

From the executing account's storage, load the 32 bytes stored at the index specified by the 32 bytes at `INDEXPTR` in linear memory into the.

```k
    syntax HostCall ::= "eei.storageLoad"
 // -------------------------------------
    rule <k> eei.storageLoad => #gatherParams(eei.storageLoad, (INDEXPTR, 32)) ... </k>
         <locals> ... 0 |-> <i32> INDEXPTR ... </locals>

    rule <k> #gatheredCall(eei.storageLoad) => #waiting(eei.storageLoad) ... </k>
         <paramstack> INDEX : .ParamStack => .ParamStack </paramstack>
         <eeiK> . => EEI.getAccountStorage INDEX </eeiK>

    rule <k> #waiting(eei.storageLoad) => #storeEeiResult(RESULTPTR, 32, VALUE) ... </k>
         <locals> ... 1 |-> <i32> RESULTPTR ... </locals>
         <eeiK> #result(VALUE) => . </eeiK>
         <statusCode> EVM_SUCCESS </statusCode>
```

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
         <eeiK> . => EEI.setAccountStorage INDEX VALUE </eeiK>

    rule <k> #waiting(eei.storageStore) => . ... </k>
         <statusCode> EVM_SUCCESS </statusCode>
```

```k
endmodule
```
