Config at node 208 is:
  #Not ( #Not ( {
    lengthBytes ( ADDRESS )
  #Equals
    20
  } ) )
#And
  #Not ( {
    notBool 4 +Int lengthBytes ( ADDRESS ) >=Int 4
  #Equals
    true
  } )
#And
  #True
#And
  <ewasm>
    <eei>
      <eeiK>
        .
      </eeiK>
      <statusCode>
        _0
      </statusCode>
      <returnData>
        b""
      </returnData>
      <callState>
        <callDepth>
          0
        </callDepth>
        <acct>
          CONTRACT_ADDR
        </acct>
        <program>
          .Code
        </program>
        <caller>
          ACCTFROM
        </caller>
        <callData>
          b"9993021a" +Bytes ADDRESS
        </callData>
        <callValue>
          0
        </callValue>
        <gas>
          0
        </gas>
      </callState>
      <callStack>
        .List
      </callStack>
      <substate>
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
            _12:Int
          </code>
          <storage>
            .Map
          </storage>
          <nonce>
            0
          </nonce>
        </account>
      </accounts>
      <accountsStack>
        .List
      </accountsStack>
      <tx>
        <gasPrice>
          0
        </gasPrice>
        <origin>
          0
        </origin>
      </tx>
      <block>
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
        call $do_balance ~> br 1  .EmptyStmts ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> block .TypeDecls i32 . const 0  i32 . load  i32 . const 3181327709  i32 . eq  i32 . eqz  br_if 0  call $do_transfer  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  call $revert  .EmptyStmts ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> label [ .ValTypes ] { .EmptyStmts } .ValStack ~> frame _12 .ValTypes .ValStack .Map 0 .Map
      </k>
      <valstack>
        .ValStack
      </valstack>
      <curFrame>
        <locals>
          .Map
        </locals>
        <localIds>
          .Map
        </localIds>
        <curModIdx>
          _12:Int
        </curModIdx>
        <labelDepth>
          3
        </labelDepth>
        <labelIds>
          .Map
        </labelIds>
      </curFrame>
      <moduleRegistry>
        .Map
      </moduleRegistry>
      <moduleIds>
        .Map
      </moduleIds>
      <moduleInstances>
        <moduleInst>
          <modIdx>
            _12
          </modIdx>
          <exports>
            "main" |-> #freshId ( 0 )
            "memory" |-> #freshId ( 1 )
          </exports>
          <typeIds>
            .Map
          </typeIds>
          <types>
            0 |-> [ i32  i32  .ValTypes ] -> [ .ValTypes ]
            1 |-> [ .ValTypes ] -> [ i32  .ValTypes ]
            2 |-> [ i32  i32  i32  .ValTypes ] -> [ .ValTypes ]
            3 |-> [ i32  .ValTypes ] -> [ .ValTypes ]
            4 |-> [ .ValTypes ] -> [ .ValTypes ]
            5 |-> [ i64  .ValTypes ] -> [ i64  .ValTypes ]
          </types>
          <nextTypeIdx>
            6
          </nextTypeIdx>
          <funcIds>
            #freshId ( 0 ) |-> 7
            $callDataCopy |-> 3
            $do_balance |-> 8
            $do_transfer |-> 9
            $finish |-> 1
            $getCallDataSize |-> 2
            $getCaller |-> 6
            $i64.reverse_bytes |-> 10
            $revert |-> 0
            $storageLoad |-> 4
            $storageStore |-> 5
          </funcIds>
          <funcAddrs>
            0 |-> 0
            1 |-> 1
            2 |-> 2
            3 |-> 3
            4 |-> 4
            5 |-> 5
            6 |-> 6
            7 |-> 7
            8 |-> 8
            9 |-> 9
            10 |-> 10
          </funcAddrs>
          <nextFuncIdx>
            11
          </nextFuncIdx>
          <tabIds>
            .Map
          </tabIds>
          <tabAddrs>
            .Map
          </tabAddrs>
          <memIds>
            #freshId ( 1 ) |-> 0
          </memIds>
          <memAddrs>
            0 |-> _17:Int
          </memAddrs>
          <globIds>
            .Map
          </globIds>
          <globalAddrs>
            .Map
          </globalAddrs>
          <nextGlobIdx>
            0
          </nextGlobIdx>
        </moduleInst>
      </moduleInstances>
      <nextModuleIdx>
        _12 +Int 1
      </nextModuleIdx>
      <mainStore>
        <funcs>
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
              _12
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
              _12
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
              _12
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
              _12
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
              _12
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
              _12
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
              _12
            </fModInst>
          </funcDef> <funcDef>
            <fAddr>
              7
            </fAddr>
            <fCode>
              block .TypeDecls block .TypeDecls call $getCallDataSize  i32 . const 4  i32 . ge_u  br_if 0  i32 . const 0  i32 . const 0  call $revert  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  i32 . const 4  call $callDataCopy  block .TypeDecls i32 . const 0  i32 . load  i32 . const 436376473  i32 . eq  i32 . eqz  br_if 0  call $do_balance  br 1  .EmptyStmts end  block .TypeDecls i32 . const 0  i32 . load  i32 . const 3181327709  i32 . eq  i32 . eqz  br_if 0  call $do_transfer  br 1  .EmptyStmts end  i32 . const 0  i32 . const 0  call $revert  .EmptyStmts end  .EmptyStmts
            </fCode>
            <fType>
              [ .ValTypes ] -> [ .ValTypes ]
            </fType>
            <fLocal>
              [ .ValTypes ]
            </fLocal>
            <fModInst>
              _12
            </fModInst>
          </funcDef> <funcDef>
            <fAddr>
              8
            </fAddr>
            <fCode>
              block .TypeDecls block .TypeDecls call $getCallDataSize  i32 . const 24  i32 . eq  br_if 0  i32 . const 0  i32 . const 0  call $revert  br 1  .EmptyStmts end  i32 . const 0  i32 . const 4  i32 . const 20  call $callDataCopy  i32 . const 0  i32 . const 32  call $storageLoad  i32 . const 32  i32 . const 32  i64 . load  call $i64.reverse_bytes  i64 . store  i32 . const 32  i32 . const 8  call $finish  .EmptyStmts end  .EmptyStmts
            </fCode>
            <fType>
              [ .ValTypes ] -> [ .ValTypes ]
            </fType>
            <fLocal>
              [ .ValTypes ]
            </fLocal>
            <fModInst>
              _12
            </fModInst>
          </funcDef> <funcDef>
            <fAddr>
              9
            </fAddr>
            <fCode>
              block .TypeDecls block .TypeDecls call $getCallDataSize  i32 . const 32  i32 . eq  br_if 0  i32 . const 0  i32 . const 0  call $revert  br 1  .EmptyStmts end  i32 . const 0  call $getCaller  i32 . const 32  i32 . const 4  i32 . const 20  call $callDataCopy  i32 . const 64  i32 . const 24  i32 . const 8  call $callDataCopy  i32 . const 64  i64 . load  call $i64.reverse_bytes  local.set 0  i32 . const 0  i32 . const 64  call $storageLoad  i32 . const 64  i64 . load  local.set 1  i32 . const 32  i32 . const 64  call $storageLoad  i32 . const 64  i64 . load  local.set 2  block .TypeDecls local.get 0  local.get 1  i64 . le_u  br_if 0  i32 . const 0  i32 . const 0  call $revert  br 1  .EmptyStmts end  local.get 1  local.get 0  i64 . sub  local.set 1  local.get 2  local.get 0  i64 . add  local.set 2  i32 . const 64  local.get 1  i64 . store  i32 . const 0  i32 . const 64  call $storageStore  i32 . const 64  local.get 2  i64 . store  i32 . const 32  i32 . const 64  call $storageStore  .EmptyStmts end  .EmptyStmts
            </fCode>
            <fType>
              [ .ValTypes ] -> [ .ValTypes ]
            </fType>
            <fLocal>
              [ i64  i64  i64  .ValTypes ]
            </fLocal>
            <fModInst>
              _12
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
              _12
            </fModInst>
          </funcDef>
        </funcs>
        <nextFuncAddr>
          11
        </nextFuncAddr>
        <tabs>
          _200
        </tabs>
        <nextTabAddr>
          _210
        </nextTabAddr>
        <mems>
          <memInst>
            <mAddr>
              _17
            </mAddr>
            <mmax>
              .Int
            </mmax>
            <msize>
              1
            </msize>
            <mdata>
              ByteMap <| 0 |-> 153
              1 |-> 147
              2 |-> 2
              3 |-> 26 |>
            </mdata>
          </memInst>
        </mems>
        <nextMemAddr>
          _17 +Int 1
        </nextMemAddr>
        <globals>
          _220
        </globals>
        <nextGlobAddr>
          _230
        </nextGlobAddr>
      </mainStore>
      <deterministicMemoryGrowth>
        DotVar10
      </deterministicMemoryGrowth>
      <nextFreshId>
        2
      </nextFreshId>
    </wasm>
    <paramstack>
      .ParamStack
    </paramstack>
  </ewasm>
#And
  {
    0 <=Int 4 +Int lengthBytes ( ADDRESS ) andBool 4 +Int lengthBytes ( ADDRESS ) <Int 4294967296
  #Equals
    true
  }
#And
  {
    4 +Int lengthBytes ( ADDRESS ) >=Int 4
  #Equals
    true
  }
#And
  {
    4 <=Int 4 +Int lengthBytes ( ADDRESS )
  #Equals
    true
  }
#And
  {
    lengthBytes ( ADDRESS )
  #Equals
    20
  }
