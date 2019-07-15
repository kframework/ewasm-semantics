#createContract 42
  (module
    (func $getCaller (import "ethereum" "getCaller") (param i32))
    (memory (export "memory") 1)
    (func (export "main")
      (call $getCaller (i32.const 0))
    )
  )

#invokeContract 256 42 .List

#assertMemoryData (1, 1) "Store getCaller is little endian"
#clearEwasmConfig