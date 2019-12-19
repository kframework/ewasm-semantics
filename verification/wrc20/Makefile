BUILD_DIR:=../.build

TMPLS:=../module-tmpl.k ../spec-tmpl.k

SPEC_GROUP:=wrc20
SPEC_INI:=wrc20_fast_transfer.ini

SPEC_NAMES:=balance nop

include ../resources/kprove.mak

KEWASM?=$(ROOT)/kewasm

%.k: %.wast
	$(KEWASM) kast $< pretty | python preprocessor.py > $@

