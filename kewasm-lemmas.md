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

  rule substrBytes(B, 0, END) => B
    requires lengthBytes(B) ==Int END
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
// TODO: We should be able to remove this one, it combines the two above and the one below.
  rule #wrap(BITLENGTH, Bytes2Int(BS, SIGN, Unsigned)) => Bytes2Int(BS, SIGN, Unsigned)
    requires lengthBytes(BS) *Int 8 <=Int BITLENGTH
    [simplification]

    rule #wrap(WIDTH, N) => N requires 0 <=Int N andBool N <Int (1 <<Int WIDTH) [simplification]

```

```k
endmodule
```
