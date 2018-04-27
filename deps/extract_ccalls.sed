#! /bin/sed -f
# Replace multiple spaces by a single one, trim leading and trailing spaces,
# discard C++ comments.
:cleanup
s/[ \t][ \t]*/ /g
s/^ //
s/ $//
s/ *\/\/.*//
# Join continuation lines.
/^NC_FUNCTION .*[^;]$/{N;s/\n//;b cleanup}
# Delete non-api lines.
/^NC_FUNCTION /!d
s/^NC_FUNCTION //
# Remove spaces before argument list parenthesis.
s/^\([_A-Za-z][_A-Za-z0-9]*\) \([_A-Za-z][_A-Za-z0-9]*\) (/\1 \2(/
# Print the original prototype as a comment.
s/^/# /; p; s/^# //
# Suppress `const`.
s/\([(,]\) *const /\1/g
# Replace `NcImageSaved *` by `NcImageSaved` (idem for `NcStatsCtx`).
s/\([(,]\) *\(NcImageSaved\|NcStatsCtx\) *\* */\1\2 /g
# Replace `struct tm` by `TmStruct`.
s/\([(,]\) *struct tm\([^_A-Za-z0-9]\)/\1TmStruct\2/g
# Replace known types by their Julia equivalent.
s/\(^\|[^_A-Za-z0-9]\)\(long\|short\) int\([^_A-Za-z0-9]\)/\1\2\3/g
s/\(^\|[^_A-Za-z0-9]\)long long\([^_A-Za-z0-9]\)/\1Clonglong\2/g
s/\(^\|[^_A-Za-z0-9]\)unsigned \(char\|short\|int\|long\|longlong\)\([^_A-Za-z0-9]\)/\1Cu\2\3/g
s/\(^\|[^_A-Za-z0-9]\)\(char\|short\|int\|long\|double\|float\)\([^_A-Za-z0-9]\)/\1C\2\3/g
s/\([(,]\) *void\([^_A-Za-z0-9]\)/\1Void\2/g
s/\(^\|[^_A-Za-z0-9]\)uint\([0-9][0-9]*\)_t\([^_A-Za-z0-9]\)/\1UInt\2\3/g
s/\(^\|[^_A-Za-z0-9]\)int\([0-9][0-9]*\)_t\([^_A-Za-z0-9]\)/\1Int\2\3/g
# Replace return type `Cint` by `Status`.
s/^Cint /Status /
# Replace enums.
#s/\(^\|[^_A-Za-z0-9]\)enum /\1Enum/g
s/\(^\|[^_A-Za-z0-9]\)enum /\1 /g
# Replace `arg[]` by `*arg`.
:array
s/\([_A-Za-z][_A-Za-z0-9]*\) *\[[ 0-9]*\]/* \1/g
t array
# Replace callbacks.
:callbaks
s/\([(,]\) *\([_A-Za-z][_A-Za-z0-9]*\) *(\([ *]*[_A-Za-z][_A-Za-z0-9]*\)) *([_A-Za-z0-9, *]*)/\1\2Callback \3/g
t callbaks
# Deal with pointers.
:pointers
s/\([(,]\) *\([_A-Za-z][_A-Za-z0-9{}]*\) *\* */\1Ptr{\2} /g
t pointers
# Replace `TYPE ARG` by `ARG::TYPE` and fix `ARG` being a Julia keyword
:args
s/\([(,]\) *\([_A-Za-z][_A-Za-z0-9{}]*\) \([_A-Za-z][_A-Za-z0-9]*\) *\([),]\)/\1\3::\2\4/g
t args
s/\([^_A-Za-z0-9]\)\(type\|abstract\|begin\|end\)::/\1_\2::/g
# Copy current pattern space in hold space (for further reprocessings).
h
# Make the current pattern space into a Julia function signature and print it.
s/\([_A-Za-z][_A-Za-z0-9{}]*\) \([_A-Za-z].*\);$/@inline \2 =/
s/, */, /g;s/( */(/g;s/ *)/)/g
p
# Copy hold space in pattern space and convert it into the first part of the ccall.
g
s/^\([_A-Za-z][_A-Za-z0-9{}]*\) \([_A-Za-z][_A-Za-z0-9]*\).*/    ccall((:\2, libnuvu), \1,/
p
# Copy hold space in pattern space, extract argument list,
# strip spaces and copy it in the hold space.
g
s/^\([_A-Za-z][_A-Za-z0-9{}]*\) \([_A-Za-z][_A-Za-z0-9]*\) *(\(.*\)) *;$/\3/
s/ //g
h
# Extract the list of types (taking care of single element tuple).
s/\([_A-Za-z][_A-Za-z0-9]*\):://g
s/^\([^,]*\)$/\1,/
s/ *, */, /g
s/^\(.*\)/          (\1),/
p
# Extract the list of arguments.
g
s/::\([_A-Za-z][_A-Za-z0-9{}]*\)//g
s/ *, */, /g
s/^\(.*\)/          \1)/
p
s/.*//
