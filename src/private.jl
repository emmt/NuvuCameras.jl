#
# private.jl -
#
# Private module with stuff hidden to the end-user.  All methods, types and
# constants defined here are made available with the prefix `Priv.`.
#

# This method is meant to be extended.
function finalize end

# faster than convert(String,buf[1:end-1])
newstring(buf::Vector{<:Union{Int8,UInt8}}) =
    unsafe_string(pointer(buf))

newstring(buf::Vector{<:Union{Int8,UInt8}}, len::Integer) =
    unsafe_string(pointer(buf), len)
