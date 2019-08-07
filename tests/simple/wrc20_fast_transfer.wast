#createContract 42
(module

;;    Copyright 2019 Paul Dworzanski et al.
;;    This file is part of c_ewasm_contracts.
;;    c_ewasm_contracts is free software: you can redistribute it and/or modify
;;    it under the terms of the GNU General Public License as published by
;;    the Free Software Foundation, either version 3 of the License, or
;;    (at your option) any later version.
;;    c_ewasm_contracts is distributed in the hope that it will be useful,
;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;    GNU General Public License for more details.
;;    You should have received a copy of the GNU General Public License
;;    along with c_ewasm_contracts.  If not, see <https://www.gnu.org/licenses/>.
;;

;; Edited with permission by Rikard Hjort, 2019.
;; Edits:
;; * (set|get)_local => local.(set|get)

  (func $revert (import "ethereum" "revert") (param i32 i32))
  (func $finish (import "ethereum" "finish") (param i32 i32))
  (func $getCallDataSize (import "ethereum" "getCallDataSize") (result i32))
  (func $callDataCopy    (import "ethereum" "callDataCopy") (param i32 i32 i32))
  (func $storageLoad     (import "ethereum" "storageLoad") (param i32 i32))
  (func $storageStore    (import "ethereum" "storageStore") (param i32 i32))
  (func $getCaller       (import "ethereum" "getCaller") (param i32))
  (memory (export "memory") 1)
  (func (export "main")
    block
      block
        call $getCallDataSize
        i32.const 4
        i32.ge_u
        br_if 0
        i32.const 0
        i32.const 0
        call $revert
        br 1
      end
      i32.const 0	;;selector, 4 bytes
      i32.const 0
      i32.const 4
      call $callDataCopy
      block
        i32.const 0	;;load selector
        i32.load
        i32.const 0x1a029399
        i32.eq
        i32.eqz
        br_if 0
        call $do_balance
        br 1
      end
      block
        i32.const 0	;;load selector
        i32.load
        i32.const 0xbd9f355d
        i32.eq
        i32.eqz
        br_if 0
        call $do_transfer
        br 1
      end
      i32.const 0
      i32.const 0
      call $revert
    end)
  (func $do_balance
    block
      block
        call $getCallDataSize
        i32.const 24
        i32.eq
        br_if 0
        i32.const 0
        i32.const 0
        call $revert
        br 1
      end
      i32.const	0	;;address to bytes 0-31, last 12 bytes are 0-padded
      i32.const 4
      i32.const 20
      call $callDataCopy
      i32.const 0	;; get token balance of address in bytes 0-31, put in bytes 32-63
      i32.const 32
      call $storageLoad
      i32.const 32	;; reverse bytes and put back in memory
      i32.const 32
      i64.load
      call $i64.reverse_bytes
      i64.store
      i32.const 32 	;; return first 8 bytes of balance
      i32.const 8
      call $finish
    end)
  (func $do_transfer
    (local i64 i64 i64)	;;sender_balance, recipient_balance, value
    block
      block
        call $getCallDataSize
        i32.const 32
        i32.eq
        br_if 0
        i32.const 0
        i32.const 0
        call $revert
        br 1
      end
      ;; memory bytes  0          32            64
      ;;               senderAddy recipientAddy tmpForTokenValues
      i32.const 0 	;;sender address to bytes 0-19 (storage key uses bytes 0-31)
      call $getCaller
      i32.const	32	;;recipient address to bytes 32-51 (storage key uses bytes 32-63)
      i32.const 4
      i32.const 20
      call $callDataCopy
      i32.const	64	;;temporarily put transfer_value in bytes 64-71, reverse 8 msb, put in in local 0
      i32.const 24
      i32.const 8
      call $callDataCopy
      i32.const 64
      i64.load
      call $i64.reverse_bytes
      local.set 0
      i32.const 0	;;temporarily put sender_balance into bytes 64-95, reverse 8 msb, put it in local 1
      i32.const 64
      call $storageLoad
      i32.const 64
      i64.load
      local.set 1
      i32.const 32	;;temporarily put recipient_balance into bytes 64-95, reverse 8 msb, put in local 2
      i32.const 64
      call $storageLoad
      i32.const 64
      i64.load
      local.set 2
      block ;; if transver_value < sender_balance, then revert
        local.get 0
        local.get 1
        i64.le_u
        br_if 0
        i32.const 0
        i32.const 0
        call $revert
        br 1
      end
      local.get 1	;;sender_balance -= value
      local.get 0
      i64.sub
      local.set 1
      local.get 2	;;recipient_balance += value
      local.get 0
      i64.add
      local.set 2
      i32.const 64 	;;reverse sender_balance, write to memory, put in storage
      local.get 1
      i64.store
      i32.const 0
      i32.const 64
      call $storageStore
      i32.const 64 	;;reverse recipient_balance, write to memory, put in storage
      local.get 2
      i64.store
      i32.const 32
      i32.const 64
      call $storageStore
    end)
  (func $i64.reverse_bytes (param i64) (result i64)
    (local i64 i64)	;;iter variable, val to return
    block
      loop
        local.get 1	;;iter variable
        i64.const 8
        i64.ge_u
        br_if 1
        local.get 0	;;original
        i64.const 56	;;shift left
        local.get 1
        i64.const 8
        i64.mul
        i64.sub
        i64.shl
        i64.const 56	;;shift right
        i64.shr_u
	i64.const 56	;;shift left
        i64.const 8
        local.get 1
        i64.mul
        i64.sub
        i64.shl
        local.get 2	;;update
        i64.add
        local.set 2
        local.get 1	;;iter+=1
        i64.const 1
        i64.add
        local.set 1
        br 0
      end
    end
    local.get 2
  )
)

;; SETUP
;; This version does fast transfers by storing the token balances in little-endian, only having to reverse them for returning balnace in beig-endian form.

#setStorage 42 :
            "\eD" "\09" "\37" "\5D" "\C6" "\B2" "\00" "\50" "\d2" "\42" "\d1" "\61" "\1a" "\f9" "\7e" "\E4" "\A6" "\E9" "\3C" "\Ad" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" |->
            1000000

;; TESTS

#invokeContract 1337 42
  (; selector "balance" ;) "\99" "\93" "\02" "\1a"
  (; address  ;) "\ed" "\09" "\37" "\5d" "\c6" "\b2" "\00" "\50" "\d2" "\42" "\d1" "\61" "\1a" "\f9" "\7e" "\e4" "\a6" "\e9" "\3c" "\ad"
#assertReturnData "\00" "\00" "\00" "\00" "\00" "\0f" "\42" "\40" "Test case 1"

#invokeContract
  (; sender ;)   "\eD" "\09" "\37" "\5D" "\C6" "\B2" "\00" "\50" "\d2" "\42" "\d1" "\61" "\1a" "\f9" "\7e" "\E4" "\A6" "\E9" "\3C" "\Ad" "\e9" "\29" "\CF" "\25" "\44" "\36" "\3b" "\dC" "\EE" "\4a" "\97" "\65" "\15" "\d5" "\F9" "\77" "\58" "\Ef" "\47" "\6c"
  (; contract ;) 42
    (; selector "transfer" ;) "\5d" "\35" "\9f" "\bd"
    (; recipient ;) "\e9" "\29" "\cf" "\25" "\44" "\36" "\3b" "\dc" "\ee" "\4a" "\97" "\65" "\15" "\d5" "\f9" "\77" "\58" "\ef" "\47" "\6c" "\00" "\00" "\00" "\00" "\00"
    (; amount ;) "\07" "\a1" "\20"
#assertReturnData "" "Test case 2"

#invokeContract 666 42
  (; selector "balance" ;) "\99" "\93" "\02" "\1a"
  (; address ;) "\ed" "\09" "\37" "\5d" "\c6" "\b2" "\00" "\50" "\d2" "\42" "\d1" "\61" "\1a" "\f9" "\7e" "\e4" "\a6" "\e9" "\3c" "\ad"
#assertReturnData "\00" "\00" "\00" "\00" "\00"  "\07" "\a1" "\20" "Test case 3"

#invokeContract 1234567890 42
  (; selector "balance" ;) "\99" "\93" "\02" "\1a"
  (; address ;) "\e9" "\29" "\cf" "\25" "\44" "\36" "\3b" "\dc" "\ee" "\4a" "\97" "\65" "\15" "\d5" "\f9" "\77" "\58" "\ef" "\47" "\6c"
#assertReturnData "\00" "\00" "\00" "\00" "\00"  "\07" "\a1" "\20" "Test case 4"

#clearEwasmConfig