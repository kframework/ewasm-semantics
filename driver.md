Ethereum Simulation
===================

```k
require "ewasm.k"

module ETHEREUM-SIMULATION
    imports EWASM
```

An Ewasm program is the invocation of an Ethereum contract containing Ewasm code.

Helper functions
----------------

Ethereum addresses are most often given in hexadecimal form.
To facilitate using addresses directly, we introduce `HexAddress`.

```k
    syntax HexAddress ::= r"0x[0-9a-fA-F]{40}"           [token, avoid]
    syntax Address    ::= Int | HexAddress
    syntax String     ::= #Address2String ( HexAddress ) [function, functional, hook(STRING.token2string)]
    syntax Int        ::= #parseAddress(HexAddress)      [function]
 // ---------------------------------------------------------
    rule #parseAddress(EA) => String2Base(replaceFirst(#Address2String(EA), #parseWasmString("0x"), #parseWasmString("")), 16)
```

Running smart contracts
-----------------------

Execution of Ethereum code is always triggered by a single transaction.
To test and query the blockchain state, we also allow direct client calls in the form of EEIMethods. 

```k
    syntax Stmt ::= EthereumCommand
 // -------------------------------
```

```k
    syntax EthereumCommand ::= "#invokeContract" Address Address Bytes
 // ------------------------------------------------------------------
    rule <k> #invokeContract ACCTFROM:HexAddress ACCTTO CALLDATA
          => #invokeContract #parseAddress(ACCTFROM) ACCTTO CALLDATA ... </k>
    rule <k> #invokeContract ACCTFROM:Int ACCTTO:HexAddress CALLDATA
          => #invokeContract ACCTFROM #parseAddress(ACCTTO) CALLDATA ... </k>
    rule <k> #invokeContract ACCTFROM:Int ACCTTO:Int CALLDATA => (invoke FADDR) ... </k>
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
    syntax EthereumCommand ::= "#createContract" Address ModuleDecl
 // ---------------------------------------------------------------
    rule <k> #createContract ADDRESS:HexAddress CODE => #createContract #parseAddress(ADDRESS) CODE ... </k>
    rule <k> #createContract ADDRESS:Int        CODE => CODE ~> #storeModuleAt ADDRESS              ... </k>

    syntax EthereumCommand ::= "#storeModuleAt" Address
 // ---------------------------------------------------
    rule <k> #storeModuleAt ADDRESS:HexAddress => #storeModuleAt #parseAddress(ADDRESS) ... </k>
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
