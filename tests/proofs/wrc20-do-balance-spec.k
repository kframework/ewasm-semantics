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
          Int2Bytes(4, 436376473, LE) +Bytes ADDRESS
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
            (Bytes2Int (ADDRESS, LE, Unsigned) |-> BALANCE:Int)
            CONTRACT_STORAGE
          </storage>
          ...
        </account>
        // ADD ...
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
          <types> // SPECIALIZE
            0 |-> [ i32  i32  .ValTypes ] -> [ .ValTypes ]
            1 |-> [ .ValTypes ] -> [ i32  .ValTypes ]
            2 |-> [ i32  i32  i32  .ValTypes ] -> [ .ValTypes ]
            3 |-> [ i32  .ValTypes ] -> [ .ValTypes ]
            4 |-> [ .ValTypes ] -> [ .ValTypes ]
            5 |-> [ i64  .ValTypes ] -> [ i64  .ValTypes ]
          </types>
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
              ByteMap <| .Map |> => ?_
            </mdata>
          </memInst>
          // ADD ...
        </mems>
        ...
      </mainStore>
      ...
    </wasm>
    <paramstack>
      .ParamStack
    </paramstack>
  </ewasm>
  requires lengthBytes(ADDRESS) ==Int 20
   andBool #inUnsignedRange(i64, BALANCE)


endmodule
