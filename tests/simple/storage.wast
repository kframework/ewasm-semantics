#createContract 42
  (module
  (func $storageLoad     (import "ethereum" "storageLoad")  (param i32 i32))
  (func $storageStore    (import "ethereum" "storageStore") (param i32 i32))
  (memory (export "memory") 1)
    (func (export "main")
      ;; Store value in bytes 0-31.
      (i64.store (i32.const  0) (i64.const 1)) ;; Value.
      (i64.store (i32.const  8) (i64.const 2)) ;; Value.
      (i64.store (i32.const 16) (i64.const 3)) ;; Value.
      (i64.store (i32.const 24) (i64.const 4)) ;; Value.

      ;; Store the address 2^255 in bytes 32-63.
      (i32.store8 (i32.const 63) (i32.const 128)) ;; Index.

      ;; Store the 32 bytes at index 0 in the contract storage at the 32-byte address at index 32-63.
      (call $storageStore (i32.const 32) (i32.const 0))

      (call $storageLoad (i32.const 32) (i32.const 256))
    )
  )

#invokeContract 256 42 ""

#assertMemoryData (256, 1) "Value was correctly loaded"
#assertMemoryData (264, 2) "Value was correctly loaded"
#assertMemoryData (272, 3) "Value was correctly loaded"
#assertMemoryData (280, 4) "Value was correctly loaded"

#clearEwasmConfig
