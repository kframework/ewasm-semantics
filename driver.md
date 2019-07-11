Ethereum Simulation
===================

```k
require "ewasm.k"

module ETHEREUM-SIMULATION
    imports EWASM
    
    configuration
      <sim> $PGM:EthereumSimulation </sim>
      <ewasm/>
```

An EWasm program is the invocation of an Ethereum contract containing EWasm code.

Running smart contracts
-----------------------

Execution of Ethereum code is always triggered by a sinlge transaction.
To test and query the blockchain state, we also allow direct client calls in the fomr of EEIMethods.

```k
    syntax EthereumSimulation ::= List{EthereumCommand, ""}
 // -------------------------------------------------------
```

```k
    syntax EthereumCommand ::= "#transfer" Int Int List
 // ---------------------------------------------------
    rule <sim> #transfer ACCTFROM ACCTTO CALLDATA ES:EthereumSimulation => ES </sim>
         <k> _ => CODE </k>
         <acct> _=> ACCTFROM </acct>_
         <account>
           <id> ACCTO </id>
           <code> CODE </code>
           ...
         </account>
```

Setting up the blockchain state
-------------------------------

```k
    syntax EthereumCommand ::= "#createContract" Int Code
 // -----------------------------------------------------
    rule <sim> #createContract ADDRESS CODE ES:EthereumSimulation => ES </sim>
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
