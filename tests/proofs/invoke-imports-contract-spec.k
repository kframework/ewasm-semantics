requires "ewasm-test.k"
requires "kwasm-lemmas.k"

module VERIFICATION
  imports EWASM-TEST
  imports KWASM-LEMMAS
endmodule

module INVOKE-COMPLEX
  imports VERIFICATION

  rule
    <ewasm>
      <eei>
        <eeiK>
          .
        </eeiK>
        <statusCode>
          _ => ?_
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
      (func String2Identifier("$revert")          ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"revert\"") )          param i32 i32 .ValTypes .TypeDecls )
      (func String2Identifier("$finish")          ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"finish\"") )          param i32 i32 .ValTypes .TypeDecls )
      (func String2Identifier("$getCallDataSize") ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"getCallDataSize\"") ) result i32 .ValTypes .TypeDecls )
      (func String2Identifier("$callDataCopy")    ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"callDataCopy\"") )    param i32 i32 i32 .ValTypes .TypeDecls )
      (func String2Identifier("$storageLoad")     ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"storageLoad\"") )     param i32 i32 .ValTypes .TypeDecls )
      (func String2Identifier("$storageStore")    ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"storageStore\"") )    param i32 i32 .ValTypes .TypeDecls )
      (func String2Identifier("$getCaller")       ( import #unparseWasmString("\"ethereum\"") #unparseWasmString("\"getCaller\"") )       param i32 .ValTypes .TypeDecls )
      ( memory ( export #unparseWasmString("\"memory\"") ) 1 )
      (func String2Identifier("$main") ( export #unparseWasmString("\"main\"") ) .TypeDecls .LocalDecls .Instrs)
    ) ~> #invokeContract ACCTFROM:Int CONTRACT_ADDR:Int CALLDATA:Int => .
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
            _ => ?_
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
          .Bag => ?_
        </moduleInstances>
        <nextModuleIdx>
          _ => ?_
        </nextModuleIdx>
        <mainStore>
          _ => ?_
        </mainStore>
        <deterministicMemoryGrowth>
          true
        </deterministicMemoryGrowth>
        <nextFreshId>
           0 => ?_
        </nextFreshId>
      </wasm>
      <paramstack>
        .ParamStack
      </paramstack>
    </ewasm>
    requires true
    ensures true
endmodule
