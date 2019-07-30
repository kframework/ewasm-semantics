#createContract 42
  (module
    (memory (export "memory") 1)
    (func (export "main")
      (i64.store (i32.const 1) (i64.const 2 ^Int 64 -Int 1))
    )
  )

#invokeContract 1 42 ""

#assertMemoryData (1, 255) "Store"
#assertMemoryData (2, 255) "Store"
#assertMemoryData (3, 255) "Store"
#assertMemoryData (4, 255) "Store"
#assertMemoryData (5, 255) "Store"
#assertMemoryData (6, 255) "Store"
#assertMemoryData (7, 255) "Store"
#assertMemoryData (8, 255) "Store"
#clearEwasmConfig
