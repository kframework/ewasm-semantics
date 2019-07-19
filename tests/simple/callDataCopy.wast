#createContract 42
  (module
    (func $callDataCopy (import "ethereum" "callDataCopy") (param i32 i32 i32))
    (memory (export "memory") 1)
    (func (export "main")
      (call $callDataCopy (i32.const 0) (i32.const 0) (i32.const 8))
      (call $callDataCopy (i32.const 16) (i32.const 32) (i32.const 4))
    )
  )

#invokeContract 256 42 String2Bytes("abcdefgh________01234") ;; TODO: use datastrings when available.

#assertMemoryData (0,  97) "Get call data first 8 bytes"
#assertMemoryData (1,  98) "Get call data first 8 bytes"
#assertMemoryData (2,  99) "Get call data first 8 bytes"
#assertMemoryData (3, 100) "Get call data first 8 bytes"
#assertMemoryData (4, 101) "Get call data first 8 bytes"
#assertMemoryData (5, 102) "Get call data first 8 bytes"
#assertMemoryData (6, 103) "Get call data first 8 bytes"
#assertMemoryData (7, 104) "Get call data first 8 bytes"

#assertMemoryData (8, 0) "Get call data does not store too much."
#assertMemoryData (15, 0) "Get call data does not store too much."

#assertMemoryData (16, 48) "Get call data at 16, 4 bytes"
#assertMemoryData (17, 49) "Get call data at 16, 4 bytes"
#assertMemoryData (18, 50) "Get call data at 16, 4 bytes"
#assertMemoryData (19, 51) "Get call data at 16, 4 bytes"

#assertMemoryData (20, 0) "Get call data does not store too much."

#createContract 43
  (module
    (func $callDataCopy (import "ethereum" "callDataCopy") (param i32 i32 i32))
    (memory (export "memory") 1)
    (func (export "main")
      (call $callDataCopy (i32.const 0) (i32.const 0) (i32.const 4))
    )
  )

#invokeContract #pow(i64) -Int 1 43 String2Bytes("abc")

#assertTrap "Access outside of calldata"

#clearEwasmConfig
