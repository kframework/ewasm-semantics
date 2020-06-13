Ethereum Simulation
===================

```k
require "ewasm.md"
require "data.md"

module DRIVER-SYNTAX
    imports EWASM-SYNTAX
    imports DRIVER
endmodule

module DRIVER
    imports EWASM
```

An Ewasm program is the invocation of an Ethereum contract containing Ewasm code.

Running smart contracts
-----------------------

Execution of Ethereum code is always triggered by a single transaction.
To test and query the blockchain state, we also allow direct client calls in the form of EEIMethods.

```k
    syntax Stmt ::= EthereumCommand
 // -------------------------------
```

Depending on context, it may make sense to give call data either as bytes (the canonical representation in this implementation), as a Wasm data string, or as an integer.
When the call data represents bytes or a data string, the conversion is straight-forward.
However, when the call data is a representation, it is interpreted as big-endian; this is the convention of giving Ethereum call data, addresses and values.

```k
    syntax CallData ::= Bytes | DataString | Int
    syntax Bytes ::= CallData2Bytes(CallData) [function]
    syntax Int   ::= CallData2Int  (CallData) [function]
 // ----------------------------------------------------
    rule CallData2Bytes(CD:Bytes)      => CD
    rule CallData2Bytes(CD:DataString) => #DS2Bytes(CD)
    rule CallData2Bytes(CD:Int)        => Int2Bytes(CD, LE, Unsigned)

    rule CallData2Int(CD:Bytes)      => Bytes2Int(CD, BE, Unsigned)
    rule CallData2Int(CD:DataString) => Bytes2Int(#DS2Bytes(CD), LE, Unsigned)
    rule CallData2Int(CD:Int)        => CD
```

TODO: Don't call it "Address"
TODO: Allow using calldata for addresses.

```k
    syntax WasmInt
    syntax EthereumCommand ::= "#invokeContract" CallData CallData CallData
    syntax EthereumCommand ::= "#invoke" Int WasmString
 // ---------------------------------------------------
    rule <k> #invokeContract ACCTFROM ACCTTO CALLDATA => #invoke MODADDR #mainName ... </k>
         <acct> _ => CallData2Int(ACCTTO) </acct>
         <caller> _ => CallData2Int(ACCTFROM) </caller>
         <callData> _ => CallData2Bytes(CALLDATA) </callData>
         <returnData> _ => .Bytes </returnData>
         <account>
           <id> ACCTTO </id>
           <code> MODADDR </code>
           ...
         </account>

    rule <k> #invoke MODADDR FNAME => ( invoke FADDR ) ... </k>
         <moduleInst>
           <modIdx> MODADDR </modIdx>
           <exports> ... FNAME |-> TFIDX ... </exports>
           <funcIds> FIDS </funcIds>
           <funcAddrs> ... #ContextLookup(FIDS, TFIDX) |-> FADDR ... </funcAddrs>
           ...
         </moduleInst>
```

### End of execution

TODO: Move to Ewasm.

An Ewasm execution ends in either a call to `finish` or `revert` (controlled exit), or with a trap (exceptional exit).
In the case of a controlled exit, we want to clean up the execution state.
This works essentially as a `trap`, ending all execution in the `<k>` cell, but keeping things like assertions and ethereum commands.

```k
    rule <k> #waiting(eei.revert) => #cleanup ... </k>
         <statusCode> EVMC_REVERT  </statusCode>
    rule <k> #waiting(eei.finish) => #cleanup ... </k>
         <statusCode> EVMC_SUCCESS </statusCode>

    syntax EthereumCommand ::= "#cleanup"
 // -----------------------------------------
    rule <k> #cleanup ~> (L:Label   => .) ... </k>
    rule <k> #cleanup ~> (F:Frame   => .) ... </k>
    rule <k> #cleanup ~> (I:Instr   => .) ... </k>
    rule <k> #cleanup ~> (IS:Instrs => .) ... </k>
    rule <k> #cleanup ~> (D:Defn    => .) ... </k>
    rule <k> #cleanup ~> (DS:Defns  => .) ... </k>

    rule <k> #cleanup ~> (S:Stmt SS:Stmts => S ~> SS) ... </k>

    rule <k> (#cleanup ~> E:EthereumCommand) => E ... </k>
```

Setting up the blockchain state
-------------------------------

### Creating accounts

```k
    syntax EthereumCommand ::= "#createContract" CallData ModuleDecl
 // ----------------------------------------------------------------
    rule <k> #createContract ADDRESS CODE => text2abstract(CODE .Stmts) ~> #storeModuleAt CallData2Int(ADDRESS) ... </k>

    syntax EthereumCommand ::= "#storeModuleAt" CallData
 // ----------------------------------------------------
    rule <k> #storeModuleAt ADDRESS => . ... </k>
         <curModIdx> CUR </curModIdx>
         <accounts>
           (.Bag
         => <account>
              <id> CallData2Int(ADDRESS) </id>
              <code> CUR </code>
              ...
            </account>
           )
           ...
         </accounts>
```

### Initializing storage.

```k
    syntax EthereumCommand ::= "#setStorage"    CallData ":" CallData "|->" CallData
                             | "#setStorageAux" Int          Int            Int
 // ---------------------------------------------------------------------------
    rule <k> #setStorage ADDRESS : LOC |-> VAL => #setStorageAux CallData2Int(ADDRESS) CallData2Int(LOC) CallData2Int(VAL) ... </k>
    rule <k> #setStorageAux ADDRESS LOC VAL => . ... </k>
         <account>
           <id> ADDRESS </id>
           <storage> STORAGE => STORAGE[LOC <- VAL] </storage>
           ...
         </account>

```

```k
endmodule
```
