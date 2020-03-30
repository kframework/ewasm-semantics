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
endmodule
```
