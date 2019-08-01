Ethereum Simulation
===================

```k
require "ewasm.k"

module ETHEREUM-SIMULATION
    imports EWASM
    imports WASM-TOKEN-SYNTAX
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
    syntax Address ::= Int | WasmInt
    syntax CallData ::= Bytes | WasmInt | Int
    syntax EthereumCommand ::= "#invokeContract" Address Address CallData
 // ---------------------------------------------------------------------
    rule <k> #invokeContract ACCTFROM:Int ACCTTO:Int CALLDATA:Int => #invokeContract ACCTFROM ACCTTO Int2Bytes(CALLDATA, LE, Unsigned) ... </k>
    rule <k> #invokeContract ACCTFROM:Int ACCTTO:Int CALLDATA:Bytes => (invoke FADDR) ... </k>
         <acct> _ => ACCTTO </acct>
         <caller> _ => ACCTFROM </caller>
         <callData> _ => CALLDATA </callData>
         <account>
           <id> ACCTTO </id>
           <code> MODADDR </code>
           ...
         </account>
         <moduleInst>
           <modIdx> MODADDR </modIdx>
           <exports> ... MAINNAME |-> TFIDX ... </exports>
           <funcIds> FIDS </funcIds>
           <funcAddrs> ... #ContextLookup(FIDS, TFIDX) |-> FADDR ... </funcAddrs>
           ...
         </moduleInst>
       requires MAINNAME ==K "main":WasmString
```

Setting up the blockchain state
-------------------------------

```k
    syntax EthereumCommand ::= "#createAccount" Address Int
 // -------------------------------------------------------
    rule <k> #createAccount ADDRESS:Int BAL => . ... </k>
         <accounts>
           ( .Bag
          => <account>
               <id> ADDRESS </id>
               <balance> BAL </balance>
               ...
             </account>
           )
           ...
         </accounts>

    syntax EthereumCommand ::= "#createContract" Address ModuleDecl
 // ---------------------------------------------------------------
    rule <k> #createContract ADDRESS:Int        CODE => CODE ~> #storeModuleAt ADDRESS              ... </k>

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
