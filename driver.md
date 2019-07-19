Ethereum Simulation
===================

```k
require "ewasm.k"

module ETHEREUM-SIMULATION
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

```k
    syntax EthereumCommand ::= "#invokeContract" Int Int Bytes
 // ----------------------------------------------------------
    rule <k> #invokeContract ACCTFROM ACCTTO CALLDATA => (invoke FADDR) ... </k>
         <acct> _ => ACCTTO </acct>
         <caller> _ => ACCTFROM </caller>
         <account>
           <id> ACCTTO </id>
           <code> MODADDR </code>
           ...
         </account>
         <moduleInst>
           <modIdx> MODADDR </modIdx>
           <exports> ... "main" |-> TFIDX ... </exports>
           <funcIds> FIDS </funcIds>
           <funcAddrs> ... #ContextLookup(FIDS, TFIDX) |-> FADDR ... </funcAddrs>
           ...
         </moduleInst>
```

Setting up the blockchain state
-------------------------------

```k
    syntax EthereumCommand ::= "#createContract" Int ModuleDecl
 // -----------------------------------------------------------
    rule <k> #createContract ADDRESS CODE => CODE ~> #storeModuleAt ADDRESS ... </k>

    syntax EthereumCommand ::= "#storeModuleAt" Int
 // ----------------------------------------------
    rule <k> #storeModuleAt ADDRESS => . ... </k>
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
