#
# nctypes.jl -
#
# Definitions of types for the interface to the Nüvü Camēras SDK.
#

import Base.Libc: TmStruct

"""

All C functions to the Nüvü Camēras SDK yield a value of type `Status`.  Which
can be `NC_SUCCESS` or some other value which is an error code.

"""
struct Status; code::Cint; end

"""

`NuvuCameraError` is the type of exception thrown by calls to the C functions
of the Nüvü Camēras SDK in case of error.

"""
struct NuvuCameraError <: Exception
    func::Symbol
    status::Status
end

"""

`Name` is the union of valid types for the name of a parameter or a file.  In
practice, these are the types which can be automatically converted to a
`Cstring` by `ccall`.

"""
const Name = Union{AbstractString,Symbol}

"""

Abstract type `Handle` is the super type of all types used to store the
address of an opaque sructure.  All such types have a field `ptr` with the
pointer.

"""
abstract type Handle end

for T in (:Cam, :Grab, :Proc, :CtrlList, :CropModeSolutions,
          :ImageSaved, :StatsCtx)
    @eval begin

        struct $T <: Handle; ptr::Ptr{Void}; end

        @doc @doc(Handle) $T

    end
end

struct ImageParams{T<:Union{Cam,Grab}} <: Handle
    ptr::Ptr{Void}
end

# Pixel type for images (`unsigned short` in C code).
const Image = UInt16

const ImageBuffer{T} = Union{Ptr{T},DenseVector{T},DenseMatrix{T}}
