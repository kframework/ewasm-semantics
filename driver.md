Ethereum Simulation
===================

```k
require "ewasm.k"
require "data.k"

module DRIVER-SYNTAX
    imports EWASM-SYNTAX
    imports WASM-SYNTAX
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
In the case of an integer, the number of desired bytes needs to be specified to avoid zero bytes getting removed.

```k
    syntax CallData ::= Bytes | DataString
    syntax Bytes ::= CallData2Bytes(CallData) [function]
 // ----------------------------------------------------
    rule CallData2Bytes(CD:Bytes)      => CD
    rule CallData2Bytes(CD:DataString) => #DS2Bytes(CD)
```

```k
    syntax WasmInt
    syntax Address ::= Int | WasmInt
    syntax EthereumCommand ::= "#invokeContract" Address Address CallData
    syntax EthereumCommand ::= "#invoke" Int WasmString
 // ---------------------------------------------------------------------
    rule <k> #invokeContract ACCTFROM:Int ACCTTO:Int CALLDATA => #invoke MODADDR #mainName ... </k>
         <acct> _ => ACCTTO </acct>
         <caller> _ => ACCTFROM </caller>
         <callData> _ => CallData2Bytes(CALLDATA) </callData>
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

```k
    syntax EthereumCommand ::= "#createContract" Address ModuleDecl
 // ---------------------------------------------------------------
    rule <k> #createContract ADDRESS:Int        CODE => CODE ~> #storeModuleAt ADDRESS              ... </k>

    syntax EthereumCommand ::= "#setStorage" Address Address Address
 // ----------------------------------------------------------------
    rule <k> #setStorage ADDRESS:Int LOC:Int VAL:Int => . ... </k>
         <account>
           <id> ADDRESS </id>
           <storage> STORAGE => STORAGE[LOC <- VAL] </storage>
           ...
         </account>

    syntax EthereumCommand ::= "#storeModuleAt" Address
 // ---------------------------------------------------
    rule <k> #storeModuleAt ADDRESS:Int => . ... </k>
         <curModIdx> CUR </curModIdx>
         <accounts>
           (.Bag
         => <account>
              <id> ADDRESS </id>
              <code> CUR </code>
              ...
            </account>
           )
           ...
         </accounts>
```

```k
endmodule
```
