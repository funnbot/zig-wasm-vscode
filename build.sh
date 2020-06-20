#!/bin/sh

IN=src/main
OUT=bin/main
Z_OPT=--release-small
WLD=/usr/local/opt/llvm/bin/wasm-ld

DUMP=false
WAT=false
RUN=false
TYP=false

usage()
{
    echo "Build wasm project"
    echo ""
    echo "./build.sh"
    echo "\t-h --help"
    echo "\t-i --in=$IN"
    echo "\t-o --out=$OUT"
    echo "\t--zig-opt=$Z_OPT"
    echo "\t--wasm-ld=$WLD"
    echo "\t-d --objdump"
    echo "\t--wasm2wat"
    echo "\t-y --typings"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -i | --in)
            IN=$VALUE
            ;;
        -o | --out)
            OUT=$VALUE
            ;;
        --zig-opt)
            Z_OPT=$VALUE
            ;;
        --wasm-ld)
            WLD=$VALUE
            ;;
        -d | --dump)
            DUMP=true
            ;;
        --wasm2wat)
            WAT=true
            ;;
        -t | --typings)
            TYP=true
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done


O_DIR="$(cut -d'/' -f1 <<< $OUT)"
O_FIL="$(cut -d'/' -f2 <<< $OUT)"

zig build-lib $Z_OPT -target wasm32-freestanding $IN.zig --output-dir $O_DIR --name $O_FIL --library sdl
[ $? -eq 0 ] || exit 1

# $WLD $OUT.o -o $OUT.wasm -O3 --no-entry --allow-undefined --import-memory --export-all --verbose
# [ $? -eq 0 ] || exit 1

rm $OUT.o

if [ "$DUMP" = "true" ]; then
    wasm-objdump $OUT.wasm -x | egrep '(Import|Function|Export|Data|Custom).+| \- (func|memory|segment)\[\d+\] (memory|sig|pages|<).*'
fi

if [ "$WAT" = "true" ]; then
    wasm2wat $OUT.wasm -f --enable-all --inline-exports --inline-imports
fi

if [ "$TYP" = "true" ]; then
    scripts/gen_typings.js $IN.zig -o typings/$O_FIL.d.ts -m $O_FIL
fi