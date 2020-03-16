requires "kewasm-lemmas.k"

module VERIFICATION
  imports KEWASM-LEMMAS
  imports WRC20-LEMMAS

endmodule

module WRC20-DO-BALANCE-SPEC
  imports VERIFICATION

  rule
  <ewasm>
    <eei>
      <eeiK>
        .
      </eeiK>
      <statusCode>
        _ => EVMC_SUCCESS
      </statusCode>
      <returnData>
      // b""
        _ => ?_ // What should this be exactly?
      </returnData>
      <callState>
        <callDepth> // DELETE
          0
        </callDepth>
        <acct>
          CONTRACT_ADDR
        </acct>
        <program> // DELETE
          .Code
        </program>
        <caller> // DELETE
          ACCTFROM
        </caller>
        <callData>
          Int2Bytes(4, 436376473, LE) +Bytes ADDRESS
        </callData>
        <callValue>  // DELETE
          0
        </callValue>
        <gas> //DELETE
          0
        </gas>
      </callState>
      <callStack> //DELETE
        .List
      </callStack>
      <substate> // DELETE
        <selfDestruct>
          .Set
        </selfDestruct>
        <log>
          .List
        </log>
        <refund>
          0
        </refund>
      </substate>
      <accounts>
        <account>
          <id>
            CONTRACT_ADDR
          </id>
          <balance>
            0
          </balance>
          <code>
            CONTRACT_MODULE:Int
          </code>
          <storage>
           WRC20_CONTRACT_STORAGE
          </storage>
          <nonce>
            0
          </nonce>
        </account>
        // ADD ...
      </accounts>
      <accountsStack> // DELETE
        .List
      </accountsStack>
      <tx> // DELETE
        <gasPrice>
          0
        </gasPrice>
        <origin>
          0
        </origin>
      </tx>
      <block> // DELETE
        <hashes>
          .List
        </hashes>
        <coinbase>
          0
        </coinbase>
        <difficulty>
          0
        </difficulty>
        <number>
          0
        </number>
        <gasLimit>
          0
        </gasLimit>
        <timestamp>
          0
        </timestamp>
      </block>
    </eei>
    <wasm>
      <k>
        call String2Identifier("$do_balance") // ~> br 1  .EmptyStmts ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> block .TypeDecls i32 . const 0  i32 . load  i32 . const 3181327709  i32 . eq  i32 . eqz  br_if 0  call $do_transfer  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  call $revert  .EmptyStmts ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> frame CONTRACT_MODULE .ValTypes .ValStack .Map 0 .Map
        => #cleanup
      </k>
      <valstack>
        .ValStack
      </valstack>
      <curFrame>
        <locals>
          _ => ?_
          //.Map
        </locals>
        <localIds> // DELETE
          .Map
        </localIds>
        <curModIdx>
          CONTRACT_MODULE:Int
        </curModIdx>
        <labelDepth> // DELETE
          _ => ?_
        </labelDepth>
        <labelIds> // DELETE
          .Map
        </labelIds>
      </curFrame>
      <moduleRegistry> // DELETE
        .Map
      </moduleRegistry>
      <moduleIds> // DELETE
        .Map
      </moduleIds>
      <moduleInstances>
        <moduleInst>
          <modIdx>
            CONTRACT_MODULE
          </modIdx>
          <exports> // DELETE
            "main" |-> #freshId ( 0 )
            "memory" |-> #freshId ( 1 )
          </exports>
          <typeIds> // DELETE
            .Map
          </typeIds>
          <types> // SPECIALIZE
            0 |-> [ i32  i32  .ValTypes ] -> [ .ValTypes ]
            1 |-> [ .ValTypes ] -> [ i32  .ValTypes ]
            2 |-> [ i32  i32  i32  .ValTypes ] -> [ .ValTypes ]
            3 |-> [ i32  .ValTypes ] -> [ .ValTypes ]
            4 |-> [ .ValTypes ] -> [ .ValTypes ]
            5 |-> [ i64  .ValTypes ] -> [ i64  .ValTypes ]
          </types>
          <nextTypeIdx> // DELETE
            6
          </nextTypeIdx>
          <funcIds> // SPECIALIZE
            (#freshId ( 0 ) |-> 7)
            (String2Identifier("$callDataCopy") |-> 3)
            (String2Identifier("$do_balance") |-> 8)
            (String2Identifier("$do_transfer") |-> 9)
            (String2Identifier("$finish") |-> 1)
            (String2Identifier("$getCallDataSize") |-> 2)
            (String2Identifier("$getCaller") |-> 6)
            (String2Identifier("$i64.reverse_bytes") |-> 10)
            (String2Identifier("$revert") |-> 0)
            (String2Identifier("$storageLoad") |-> 4)
            (String2Identifier("$storageStore") |-> 5)
          </funcIds>
          <funcAddrs> // SPECIALIZE
            (0 |-> 0)
            (1 |-> 1)
            (2 |-> 2)
            (3 |-> 3)
            (4 |-> 4)
            (5 |-> 5)
            (6 |-> 6)
            (7 |-> 7)
            (8 |-> 8)
            (9 |-> 9)
            (10 |-> 10)
          </funcAddrs>
          <nextFuncIdx> // DELETE
            11
          </nextFuncIdx> // DELETE
          <tabIds>   // DELETE
            .Map
          </tabIds>
          <tabAddrs> // DELETE
            .Map
          </tabAddrs>
          <memIds>
            #freshId ( 1 ) |-> 0
          </memIds>
          <memAddrs>
            0 |-> CONTRACT_MEMORY_ADDR:Int
          </memAddrs>
          <globIds> // DELETE
            .Map
          </globIds>
          <globalAddrs> // DELETE
            .Map
          </globalAddrs>
          <nextGlobIdx> // DELETE
            0
          </nextGlobIdx>
        </moduleInst>
      </moduleInstances>
      <nextModuleIdx> // DELETE
        CONTRACT_MODULE +Int 1
      </nextModuleIdx>
      <mainStore>
        <funcs> // SPECIALIZE THE ADDRESSES
        // REMOVE ALL UNNEEDED FUNCTIONS
          <funcDef>
            <fAddr>
              0
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
          </funcDef> <funcDef>
            <fAddr>
              1
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
          </funcDef> <funcDef>
            <fAddr>
              2
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
          </funcDef> <funcDef>
            <fAddr>
              3
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
          </funcDef> <funcDef>
            <fAddr>
              4
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
          </funcDef> <funcDef>
            <fAddr>
              5
            </fAddr>
            <fCode>
              eei.storageStore  .EmptyStmts
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
          </funcDef> <funcDef>
            <fAddr>
              6
            </fAddr>
            <fCode>
              eei.getCaller  .EmptyStmts
            </fCode>
            <fType>
              [ i32  .ValTypes ] -> [ .ValTypes ]
            </fType>
            <fLocal>
              [ .ValTypes ]
            </fLocal>
            <fModInst>
              CONTRACT_MODULE
            </fModInst>
          </funcDef> <funcDef>
            <fAddr>
              7
            </fAddr>
            <fCode>
              block .TypeDecls block .TypeDecls call String2Identifier("$getCallDataSize")  i32 . const 4  i32 . ge_u  br_if 0  i32 . const 0  i32 . const 0  call String2Identifier("$revert")  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  i32 . const 4  call String2Identifier("$callDataCopy")  block .TypeDecls i32 . const 0  i32 . load  i32 . const 436376473  i32 . eq  i32 . eqz  br_if 0  call String2Identifier("$do_balance")  br 1  .EmptyStmts end  block .TypeDecls i32 . const 0  i32 . load  i32 . const 3181327709  i32 . eq  i32 . eqz  br_if 0  call String2Identifier("$do_transfer")  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  call String2Identifier("$revert")  .EmptyStmts end  .EmptyStmts
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
          </funcDef> <funcDef>
            <fAddr>
              8
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
          </funcDef> <funcDef>
            <fAddr>
              9
            </fAddr>
            <fCode>
              _
              // block .TypeDecls block .TypeDecls call String2Identifier("$getCallDataSize")  i32 . const 32  i32 . eq  br_if 0  i32 . const 0  i32 . const 0  call String2Identifier("$revert")  br 1  .EmptyStmts end  i32 . const 0  call String2Identifier("$getCaller")  i32 . const 32  i32 . const 4  i32 . const 20  call String2Identifier("$callDataCopy")  i32 . const 64  i32 . const 24  i32 . const 8  call String2Identifier("$callDataCopy")  i32 . const 64  i64 . load  call String2Identifier("$i64.reverse_bytes")  local.set 0  i32 . const 0  i32 . const 64  call String2Identifier("$storageLoad")  i32 . const 64  i64 . load  local.set 1  i32 . const 32  i32 . const 64  call String2Identifier("$storageLoad")  i32 . const 64  i64 . load  local.set 2  block .TypeDecls local.get 0  local.get 1  i64 . le_u  br_if 0  i32 . const 0  i32 . const 0  call String2Identifier("$revert")  br 1  .EmptyStmts end  local.get 1  local.get 0  i64 . sub  local.set 1  local.get 2  local.get 0  i64 . add  local.set 2  i32 . const 64  local.get 1  i64 . store  i32 . const 0  i32 . const 64  call String2Identifier("$storageStore")  i32 . const 64  local.get 2  i64 . store  i32 . const 32  i32 . const 64  call String2Identifier("$storageStore")  .EmptyStmts end  .EmptyStmts
            </fCode>
            <fType>
              [ .ValTypes ] -> [ .ValTypes ]
            </fType>
            <fLocal>
              [ i64  i64  i64  .ValTypes ]
            </fLocal>
            <fModInst>
              CONTRACT_MODULE
            </fModInst>
          </funcDef> <funcDef>
            <fAddr>
              10
            </fAddr>
            <fCode>
              block .TypeDecls loop .TypeDecls local.get 1  i64 . const 8  i64 . ge_u  br_if 1  local.get 0  i64 . const 56  local.get 1  i64 . const 8  i64 . mul  i64 . sub  i64 . shl  i64 . const 56  i64 . shr_u  i64 . const 56  i64 . const 8  local.get 1  i64 . mul  i64 . sub  i64 . shl  local.get 2  i64 . add  local.set 2  local.get 1  i64 . const 1  i64 . add  local.set 1  br 0  .EmptyStmts end  .EmptyStmts end  local.get 2  .EmptyStmts
            </fCode>
            <fType>
              [ i64  .ValTypes ] -> [ i64  .ValTypes ]
            </fType>
            <fLocal>
              [ i64  i64  .ValTypes ]
            </fLocal>
            <fModInst>
              CONTRACT_MODULE
            </fModInst>
          </funcDef>
          // ADD ...
        </funcs>
        <nextFuncAddr> // DELETE
          11
        </nextFuncAddr>
//      <tabs> // DELETE
//        _200
//      </tabs>
//      <nextTabAddr> // DELETE
//        _210
//      </nextTabAddr>
        <mems>
          <memInst>
            <mAddr>
              CONTRACT_MEMORY_ADDR
            </mAddr>
            <mmax>
              .Int
            </mmax>
            <msize>
              1
            </msize>
            <mdata>
              CONTRACT_MEMORY_BYTE_MAP => ?_
            </mdata>
          </memInst>
          // ADD ...
        </mems>
//      <nextMemAddr> // DELETE
//        CONTRACT_MEMORY_ADDR +Int 1
//      </nextMemAddr>
//      <globals> // DELETE
//        _220
//      </globals>
//      <nextGlobAddr> // DELETE
//        _230
//      </nextGlobAddr>
        ...
      </mainStore>
      <deterministicMemoryGrowth> // DELETE
        DotVar10
      </deterministicMemoryGrowth>
      <nextFreshId> // DELETE
        2
      </nextFreshId>
    </wasm>
    <paramstack>
      .ParamStack
    </paramstack>
  </ewasm>
  requires lengthBytes(ADDRESS) ==Int 20

endmodule
