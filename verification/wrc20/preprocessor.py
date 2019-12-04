# Preprocessor that converts Wasm concrete syntax into a form parseable by K.
# example usage: python convert.py f32.wast

import re
import sys

def hex2dec(h):
    if re.match(r'^0x[0-9a-fA-F]+$', h) is None:
        return h 

    h = re.sub("_", "", h)
    return str((int(h.split("0x")[1], 16))) + ":Int"


def dollar2var(token):
    if token[0] == "$":
        token = "DOLLAR__" + token[1:].upper().replace(".", "__DOT__") + ":Identifier"
    return token
        

def string2wasmstring(token):
    return re.sub(r'".*"', lambda m: '#unparseWasmString("\\"%s\\"")' % m.group()[1:-1], token)


def main():
    if len(list(sys.argv)) == 1:
        infile = sys.stdin
    else:
        infile = open(sys.argv[1])

    prog = infile.read()
    infile.close()

    output = []

    for word in prog.split():
        word = hex2dec(word)
        word = dollar2var(word)
        word = string2wasmstring(word)
        output.append(word)

    prog = " ".join(output)
    print(prog)

if __name__ == "__main__":
    main()
