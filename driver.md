Ethereum Simulation
===================

```k
require "ewasm.k"

module ETHEREUM-SIMULATION
    imports EWASM
```

An EWasm program is the invocation of an Ethereum contract containing EWasm code.

Running smart contracts
-----------------------

Execution of Ethereum code is always triggered by a sinlge transaction.
To test and query the blockchain state, we also allow direct client calls in the fomr of EEIMethods.

```k
    syntax Stmt ::= EthereumCommand
 // -------------------------------
```

```k
    syntax EthereumCommand ::= "#invokeContract" Int Int List
 // ---------------------------------------------------------
    rule <k> #transfer ACCTFROM ACCTTO CALLDATA => CODE ~> ( invoke "main" )... </k>
         <acct> _ => ACCTFROM </acct>
         <account>
           <id> ACCTTO </id>
           <code> CODE </code>
           ...
         </account>
      requires CODE =/=K .Code

```

Setting up the blockchain state
-------------------------------

```k
    syntax EthereumCommand ::= "#createContract" Int Code
 // -----------------------------------------------------
    rule <k> #createContract ADDRESS CODE => . ... </k>
         <accounts>
           (.Bag
         => <account>
              <id> ADDRESS </id>
              <code> CODE </code>
              ...
            </account>
           )
           ...
         </accounts>
        
    
```

```k
endmodule
```
