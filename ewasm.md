EWASM specification
=================

```k
require "deps/wasm-semantics/test.k"
require "deps/eei-semantics/eei.k"

module EWASM
    imports EEI
    imports WASM-TEST
    
    configuration
      <ewasm>
        <eei/>
        <wasm/>
      </ewasm>
```

Make a wasm program storable in contract code.

```k
    syntax Code ::= Stmts
```

```k
    syntax Intr ::= "eei.getCaller"
 // -------------------------------
    rule <k> eei.getCaller => . ... </k>
         <eeiK> . => EEI.getCaller </eeiK>

```

```k
endmodule
```
