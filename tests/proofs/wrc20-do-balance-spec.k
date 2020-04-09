requires "kewasm-lemmas.k"

module VERIFICATION
    imports KEWASM-LEMMAS
    imports WRC20-LEMMAS

endmodule

module WRC20-DO-BALANCE-SPEC
    imports VERIFICATION

    rule <ewasm>
           <eei>
             <eeiK>
               .
             </eeiK>
             <statusCode>
               .StatusCode => EVMC_SUCCESS
             </statusCode>
             <returnData>
               _ => Int2Bytes(8, BALANCE, LE)
             </returnData>
             <callState>
               <acct>
                 CONTRACT_ADDR
               </acct>
               <callData>
                 SELECTOR +Bytes ADDRESS
               </callData>
               ...
             </callState>
             <accounts>
               <account>
                 <id>
                   CONTRACT_ADDR
                 </id>
                 <code>
                   CONTRACT_MODULE:Int
                 </code>
                 <storage>
                   Bytes2Int(ADDRESS, LE, Unsigned) |-> BALANCE:Int
                   CONTRACT_STORAGE:Map
                 </storage>
                 ...
               </account>
               ...
             </accounts>
             ...
           </eei>
           <wasm>
             <k>
               call String2Identifier("$do_balance") => #cleanup ...
             </k>
             <curFrame>
               <locals>
                 _ => ?_
               </locals>
               <curModIdx>
                 CONTRACT_MODULE:Int
               </curModIdx>
               <labelDepth>
                 _ => ?_
               </labelDepth>
               ...
             </curFrame>
             <moduleInstances>
               <moduleInst>
                 <modIdx>
                   CONTRACT_MODULE
                 </modIdx>
                 <funcIds>
                   (String2Identifier("$revert")          |-> 0)
                   (String2Identifier("$finish")          |-> 1)
                   (String2Identifier("$getCallDataSize") |-> 2)
                   (String2Identifier("$callDataCopy")    |-> 3)
                   (String2Identifier("$storageLoad")     |-> 4)
                   (String2Identifier("$do_balance")      |-> 8)
                   FUNCS:Map
                 </funcIds>
                 <funcAddrs>
                   (0 |-> REVERT_ADDR)
                   (1 |-> FINISH_ADDR)
                   (2 |-> GET_CALL_DATA_SIZE_ADDR)
                   (3 |-> CALL_DATA_COPY_ADDR)
                   (4 |-> STORAGE_LOAD_ADDR)
                   (8 |-> DO_BALANCE_ADDR)
                   FUNC_ADDRS:Map
                 </funcAddrs>
                 <memIds>
                   #freshId ( 1 ) |-> 0
                 </memIds>
                 <memAddrs>
                   0 |-> CONTRACT_MEMORY_ADDR:Int
                 </memAddrs>
                 ...
               </moduleInst>
             </moduleInstances>
             <mainStore>
               <funcs>
                 <funcDef>
                   <fAddr>
                     REVERT_ADDR
                   </fAddr>
                   <fCode>
                     eei.revert  .EmptyStmts
                   </fCode>
                   <fType>
                     [ i32  i32  .ValTypes ] -> [ .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 <funcDef>
                   <fAddr>
                     FINISH_ADDR
                   </fAddr>
                   <fCode>
                     eei.finish  .EmptyStmts
                   </fCode>
                   <fType>
                     [ i32  i32  .ValTypes ] -> [ .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 <funcDef>
                   <fAddr>
                     GET_CALL_DATA_SIZE_ADDR
                   </fAddr>
                   <fCode>
                     eei.getCallDataSize  .EmptyStmts
                   </fCode>
                   <fType>
                     [ .ValTypes ] -> [ i32  .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 <funcDef>
                   <fAddr>
                     CALL_DATA_COPY_ADDR
                   </fAddr>
                   <fCode>
                     eei.callDataCopy  .EmptyStmts
                   </fCode>
                   <fType>
                     [ i32  i32  i32  .ValTypes ] -> [ .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 <funcDef>
                   <fAddr>
                     STORAGE_LOAD_ADDR
                   </fAddr>
                   <fCode>
                     eei.storageLoad  .EmptyStmts
                   </fCode>
                   <fType>
                     [ i32  i32  .ValTypes ] -> [ .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 <funcDef>
                   <fAddr>
                     DO_BALANCE_ADDR
                   </fAddr>
                   <fCode>
                     block .TypeDecls block .TypeDecls call String2Identifier("$getCallDataSize")  i32 . const 24  i32 . eq  br_if 0  i32 . const 0  i32 . const 0  call String2Identifier("$revert")  br 1  .EmptyStmts end  i32 . const 0  i32 . const 4  i32 . const 20  call String2Identifier("$callDataCopy")  i32 . const 0  i32 . const 32  call String2Identifier("$storageLoad")  i32 . const 32  i32 . const 32  i32 . const 8  call String2Identifier("$finish")  .EmptyStmts end  .EmptyStmts
                   </fCode>
                   <fType>
                     [ .ValTypes ] -> [ .ValTypes ]
                   </fType>
                   <fLocal>
                     [ .ValTypes ]
                   </fLocal>
                   <fModInst>
                     CONTRACT_MODULE
                   </fModInst>
                 </funcDef>
                 ...
               </funcs>
               <mems>
                 <memInst>
                   <mAddr>
                     CONTRACT_MEMORY_ADDR
                   </mAddr>
                   <msize>
                     1
                   </msize>
                   <mdata>
                     ByteMap <| .Map |> => ?_
                   </mdata>
                   ...
                 </memInst>
                 ...
               </mems>
               ...
             </mainStore>
             ...
           </wasm>
           <paramstack>
             .ParamStack
           </paramstack>
         </ewasm>
      requires lengthBytes(SELECTOR) ==Int 4
       andBool lengthBytes(ADDRESS)  ==Int 20
       andBool #inUnsignedRange(i64, BALANCE)

endmodule
