requires "kewasm-lemmas.k"

module INVOKE-CONTRACT-SPEC
  imports KEWASM-LEMMAS

  rule <statusCode>
         _ => ?_
       </statusCode>
       <returnData>
         .Bytes
       </returnData>
       <callState>
         <acct>
           _ => ?_
         </acct>
         <caller>
           _ => ?_
         </caller>
         <callData>
           _ => ?_
         </callData>
         ...
       </callState>
       <accounts>
         .Bag => ?_
       </accounts>
       <k>
         #createContract CONTRACT_ADDR:Int
         (module
           ( memory ( export #unparseWasmString("\"memory\"") ) 1 )
           (func String2Identifier("$main") ( export #unparseWasmString("\"main\"") ) .TypeDecls .LocalDecls .Instrs
           )) ~> #invokeContract ACCTFROM:Int CONTRACT_ADDR:Int CALLDATA:Bytes => .
       </k>
       <curFrame>
         <curModIdx>
           _ => ?_
         </curModIdx>
         ...
       </curFrame>
       <moduleInstances>
         .Bag => ?_
       </moduleInstances>
       <nextModuleIdx>
         _ => ?_
       </nextModuleIdx>
       <mainStore>
         <funcs>
           .Bag => ?_
         </funcs>
         <nextFuncAddr>
           _ => ?_
         </nextFuncAddr>
         <mems>
           .Bag => ?_
         </mems>
         <nextMemAddr>
           _ => ?_
         </nextMemAddr>
         ...
       </mainStore>
       <nextFreshId>
           0 => ?_
       </nextFreshId>

endmodule
