#createContract 42
  (module
    (func $getCaller (import "ethereum" "getCaller") (param i32))
    (memory (export "memory") 1)
    (func (export "main")
      (call $getCaller (i32.const 10))
    )
  )

#invokeContract 256 42 .List

#assertMemoryData (11, 1) "Store getCaller is little endian"

#createContract 43
  (module
    (func $getCaller (import "ethereum" "getCaller") (param i32))
    (memory (export "memory") 1)
    (func (export "main")
      (call $getCaller (i32.const 10))
    )
  )

#invokeContract #pow(i64) -Int 1 43 .List

#assertMemoryData (10, 255) "getCaller loads all the bytes"
#assertMemoryData (11, 255) "getCaller loads all the bytes"
#assertMemoryData (12, 255) "getCaller loads all the bytes"
#assertMemoryData (13, 255) "getCaller loads all the bytes"
#assertMemoryData (14, 255) "getCaller loads all the bytes"
#assertMemoryData (15, 255) "getCaller loads all the bytes"
#assertMemoryData (16, 255) "getCaller loads all the bytes"
#assertMemoryData (17, 255) "getCaller loads all the bytes"

#clearEwasmConfig
