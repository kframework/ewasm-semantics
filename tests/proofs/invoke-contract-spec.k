requires "kewasm-lemmas.k"

module INVOKE-CONTRACT-SPEC
  imports KEWASM-LEMMAS

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
            _ => ?_
          </acct>
          <program>
            .Code
          </program>
          <caller>
            _ => ?_
          </caller>
          <callData>
            _ => ?_
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
          .Bag => ?_
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
        <k> #createContract CONTRACT_ADDR:Int #wrc20
         ~> #invokeContract ACCTFROM:Int CONTRACT_ADDR:Int
                            (Int2Bytes(4, 436376473, LE) +Bytes ADDRESS:Bytes ) => .
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
          <funcs>
           .Bag => ?_
          </funcs>
          <nextFuncAddr>
           0 => ?_
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
        ...
      </wasm>
      <paramstack>
        .ParamStack
      </paramstack>
    </ewasm>
    requires lengthBytes(ADDRESS) ==Int 20
    ensures true
endmodule
