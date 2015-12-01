#!/bin/bash

function run {
    NAME=$1
    shift
    echo "-=-=- $NAME -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    "$@"
    CODE=$?
    if [ $CODE -ne 0 ]; then
        echo "-=-=- $NAME failed! -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        exit $CODE
    else
        echo "-=-=- End of $NAME -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    fi
}

cd $APPVEYOR_BUILD_FOLDER

echo "Build ocamlfind..."
echo "OCAMLROOT=$OCAMLROOT"
BINDIR="$OCAMLROOT/bin"
SITELIB="$OCAMLROOT/lib"
MANDIR="$OCAMLROOT/man"
CONFIG="$OCAMLROOT/etc/findlib.conf"
# ./configure -bindir "$BINDIR" -sitelib "$SITELIB" -mandir "$MANDIR" \
#             -config "$CONFIG"
./configure -mandir "$MANDIR"
run "Makefile.config" cat Makefile.config
# Set EXEC_SUFFIX (not automatically detected):
# cp Makefile.config Makefile.config.bak
# sed -e "s|EXEC_SUFFIX=.*|EXEC_SUFFIX=.exe|" Makefile.config.bak \
#     > Makefile.config
run "Build ocamlfind (byte)" make all
run "Build ocamlfind (native)" make opt
run "Install ocamlfind" make install
# Fix '\' → '\\'
# cp "$CONFIG" "findlib.conf.bak"
# sed -e "s|\\\\|\\\\\\\\|g" "findlib.conf.bak" > findlib.conf
# cp findlib.conf "$CONFIG"
# Small test:
run "findlib_config.ml" cat src/findlib/findlib_config.ml
#run "Content of $CONFIG" cat "$CONFIG"
run "Content of findlib.conf" cat "/cygdrive/c/Program Files/OCaml/etc/findlib.conf"
run "ocamlfind printconf" ocamlfind printconf
run "List" ocamlfind list
