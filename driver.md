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

```k
    syntax CallData ::= Bytes | WasmInt | Int | DataString
    syntax Bytes ::= CallData2Bytes(CallData) [function]
 // ----------------------------------------------------
    rule CallData2Bytes(CD:Bytes)      => CD
    rule CallData2Bytes(CD:Int)        => Int2Bytes(CD, LE, Unsigned)
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
