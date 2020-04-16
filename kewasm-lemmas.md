KEwasm Lemmas
=============

These lemmas aid in verifying Ewasm programs behavior.
They are part of the *trusted* base, and so should be scrutinized carefully.

```k
requires "kwasm-lemmas.k"
requires "kewasm-lemmas.k"

module KEWASM-LEMMAS
  imports EWASM-TEST
  imports KWASM-LEMMAS
```

Maps
----

These lemmas are needed for our symbolic map accesses to work for now.
They will likely be upstreamed or replaced by something similar upstream in the future.

```k
    rule K in_keys (.Map)         => false                            [simplification]
    rule K in_keys ((K  |-> _) M) => true                             [simplification]
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

    rule substrBytes(B1 +Bytes B2, START, END)
      => substrBytes(B1, START, END)
      requires lengthBytes(B1) >=Int END
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

    rule substrBytes(B, START, END) => B
      requires START ==Int 0
       andBool lengthBytes(B) ==Int END
      [simplification]
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

```k
endmodule
```
