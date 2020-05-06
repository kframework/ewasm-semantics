KEwasm Lemmas
=============

These lemmas aid in verifying Ewasm programs behavior.
They are part of the *trusted* base, and so should be scrutinized carefully.

```k
requires "kwasm-lemmas.k"

module KEWASM-LEMMAS
  imports EWASM-TEST
  imports KWASM-LEMMAS
```

Maps
----

These lemmas are needed for our symbolic map accesses to work for now.
They will likely be upstreamed or replaced by something similar upstream in the future.

```k
    rule K in_keys (.Map)         => false                              [simplification]
    rule K in_keys ((K  |-> _) M) => true                               [simplification]
    rule K in_keys ((K' |-> _) M) => K in_keys (M)  requires K =/=K K'  [simplification]

    rule ((K  |-> V) M) [ K  ]   => V                            [simplification]
    rule ((K1 |-> V) M) [ K2 ]   => M [ K2 ] requires K1 =/=K K2 [simplification]
```

Bytes
-----

Call data and return data comes in the form of `Bytes`.
Several arguments are passed in a single byte sequence, and are accessed with offsets.
To reason about the byte data, the following rules are helpful.

```k
    rule lengthBytes(B1 +Bytes B2) => lengthBytes(B1) +Int lengthBytes(B2) [simplification]
```

The following lemmas tell us that a sequence of bytes, interpreted as an integer, is withing certain limits.

```k
    rule Bytes2Int(BS, _, _) <Int N => true
      requires N >=Int (1 <<Int (lengthBytes(BS) *Int 8))
      [simplification]

    rule 0 <=Int Bytes2Int(_, _, Unsigned) => true [simplification]
```

When a value is within the range it is being wrapped to, we can remove the wrapping.

```k
    rule #wrap(BITLENGTH, Bytes2Int(BS, ENDIAN, Unsigned)) => Bytes2Int(BS, ENDIAN, Unsigned)
      requires lengthBytes(BS) *Int 8 <=Int BITLENGTH
      [simplification]
```

### Subsequences of Bytes

`substrBytes(BS, X, Y)` returns the subsequence of `BS` from `X` to `Y`, including index `X` but not index `Y`.
It is a partial function, and only defined when `Y` is larger or equal to `X` and the length of `BS` is less than or equal to `Y`.
The following lemma tells the prover when it can conclude that the function is defined.

```k
    rule #Ceil(substrBytes(@B, @START, @END))
      => { @START <=Int @END #Equals true }
         #And
         { lengthBytes(@B) <=Int @END #Equals true }
         #And #Ceil(@B) #And #Ceil(@START) #And #Ceil(@END)
      [anywhere]
```

The identity of the substring operation is when `START` is 0 and `END` is the length of the byte sequence.

```k
    rule substrBytes(B, START, END) => B
      requires START ==Int 0
       andBool lengthBytes(B) ==Int END
      [simplification]
```

The following lemmas tell us how `substrBytes` works over concatenation of bytes sequnces.
TODO: The last two don't make the expression smaller, which may be an issue?

```k
    rule substrBytes(B1 +Bytes B2, START, END)
      => substrBytes(B1, START, END)
      requires END <=Int lengthBytes(B1)
      [simplification]

    rule substrBytes(B1 +Bytes B2, START, END)
      => substrBytes(B2, START -Int lengthBytes(B1), END -Int lengthBytes(B1))
      requires lengthBytes(B1) <=Int START
      [simplification]

    rule substrBytes(B1 +Bytes B2, START, END)
      => substrBytes(B1, START,                               lengthBytes(B1))
         +Bytes
         substrBytes(B2, START -Int lengthBytes(B1), END -Int lengthBytes(B1))
      requires notBool (lengthBytes(B1) >=Int END)
       andBool notBool (lengthBytes(B1) <=Int START)
      [simplification]
```

```k
endmodule
```
