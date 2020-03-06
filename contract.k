requires "ewasm-test.k"
requires "kwasm-lemmas.k"

module VERIFICATION is
  imports EWASM-TEST
  imports KWASM-LEMMAS
endmodule

module INVOKE-SPEC
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
          .Bytes
        </returnData>
        <callState>
          <callDepth>
            0
          </callDepth>
          <acct>
            0
          </acct>
          <program>
            .Code
          </program>
          <caller>
            0
          </caller>
          <callData>
            .Bytes
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
          ACCOUNTS
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
          #createContract CONTRACT_ADDR:Int
    (module
      ( memory ( export #unparseWasmString("\"memory\"") ) 1 )
      (func ( export #unparseWasmString("\"main\"") ) .TypeDecls .LocalDecls
        block .TypeDecls
          block .TypeDecls
            call String2Identifier("$getCallDataSize")
            i32.const 4
            i32.ge_u
            br_if 0
            i32.const 0
            i32.const 0
            call String2Identifier("$revert")
            br 1
            .EmptyStmts
          end
          i32.const 0
          i32.const 0
          i32.const 4
          call String2Identifier("$callDataCopy")
          block .TypeDecls
            i32.const 0
            i32.load
            i32.const 436376473:Int
            i32.eq
            i32.eqz
            br_if 0
            call String2Identifier("$do_balance")
            br 1
            .EmptyStmts
          end
          block .TypeDecls
            i32.const 0 i32.load
            i32.const 3181327709:Int
            i32.eq
            i32.eqz
            br_if 0
            call String2Identifier("$do_transfer")
            br 1
            .EmptyStmts
          end
          i32.const 0
          i32.const 0
          call String2Identifier("$revert")
          .EmptyStmts
        end
        .EmptyStmts
      )) ~> #invokeContract ACCTFROM:Int CONTRACT_ADDR:Int CALLDATA:Int => .
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
            _ => _
          </curModIdx>
          <labelDepth>
            0
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
          .Bag => _
        </moduleInstances>
        <nextModuleIdx>
          _ => _
        </nextModuleIdx>
        <mainStore>
          _ => _
        </mainStore>
        <deterministicMemoryGrowth>
          true
        </deterministicMemoryGrowth>
        <nextFreshId>
           _ => _
        </nextFreshId>
      </wasm>
      <paramstack>
        .ParamStack
      </paramstack>
    </ewasm>
    requires true
      andBool 0 <=Int OWNER     andBool OWNER     <Int (2 ^Int 160)
      andBool 0 <=Int BAL       andBool BAL       <Int (2 ^Int 256)
    ensures true
endmodule

