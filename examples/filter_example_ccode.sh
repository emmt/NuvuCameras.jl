#! /bin/sh

exe=$(readlink -f "$0")
bindir=$(dirname "$exe")
while test $# -ge 1; do
    src="$1"
    dst=$(basename "$src" .c | sed 's/  *//g;s/$/.jl/')
    dir=$(dirname "$src")
    test -e "$dst" && mv -f "$dst" "$dst.bak"
    if test -e "$dir/ReadMe.txt"; then
        sed <"$dir/ReadMe.txt" >"$dst" -e 's/^/# /;s/\r//g;'
    fi
    "$bindir/filter_ccode.sed" <"$src" >>"$dst"
    shift
done
