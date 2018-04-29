#! /bin/sed -f
# Replace multiple spaces by a single one, trim leading and trailing spaces.
s/[ \t\r][ \t\r]*/ /g
s/^ //
s/ $//
# Delete non matching lines.
/^# *define NC_[_A-Z0-9]* [0-9][0-9]*/!d
# Substitute status.
s/^# *define NC_\([_A-Z0-9]*\) \([0-9][0-9]*\)/const \1 = Status(\2) /
s/ *\/\/ */ # /
s/ $//
