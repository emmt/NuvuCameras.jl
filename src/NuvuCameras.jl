module NuvuCameras

export
    ControllerList,
    getdetectorsize,
    getdetectortype,
    getfreeportchannel,
    getfreeportcount,
    getfreeportinterface,
    getfreeportuniqueid,
    getfreeportunit,
    getfullsize,
    getmodel,
    getplugincount,
    getpluginname,
    getportchannel,
    getportinterface,
    getportunit,
    getserial,
    getsize,
    getuniqueid

# FIXME: ncControllerListGetFreePortReason

#include("constants.jl")
const libnuvu = "/opt/NuvuCameras/lib/libnuvu.so"

#------------------------------------------------------------------------------
# DATA TYPES

mutable struct Camera
    ptr::Ptr{Void} # opaque handle
    function Camera(ptr::Ptr{Void})
        obj = new(ptr)
        if ptr != C_NULL
            #finalizer(obj, _finalize)
        end
        return obj
    end
end

mutable struct ControllerList
    ptr::Ptr{Void} # opaque handle
    cnt::Int
    function ControllerList(ptr::Ptr{Void})
        obj = new(ptr, 0)
        if ptr != C_NULL
            finalizer(obj, _finalize)
            obj.cnt = getsize(obj)
        end
        return obj
    end
end

#------------------------------------------------------------------------------
# CONTROLLER LIST METHODS

function ControllerList(basic::Bool = false)
    ref = Ref{Ptr{Void}}(0)
    if basic
        _check(ccall((:ncControllerListOpenBasic, libnuvu),
                     Cint, (Ptr{Ptr{Void}},), ref),
               :ncControllerListOpenBasic)
    else
        _check(ccall((:ncControllerListOpen, libnuvu),
                     Cint, (Ptr{Ptr{Void}},), ref),
               :ncControllerListOpen)
    end
    return ControllerList(ref[])
end

Base.length(obj::ControllerList) = obj.cnt

function _finalize(obj::ControllerList)
    if obj.ptr != C_NULL
        ptr = obj.ptr
        obj.ptr = C_NULL
        code = ccall((:ncControllerListFree, libnuvu),
                     Cint, (Ptr{Void},), ptr)
    end
    return nothing
end

"""
```julia
getfreeportunit(clist, i)
```
yields the board unit for the `i`-th unused port in list of controllers
`clist`.

"""
getfreeportunit

for (func, symb, count) in ((:getserial,
                             :ncControllerListGetSerial,
                             :length),
                            (:getmodel,
                             :ncControllerListGetModel,
                             :length),
                            (:getportinterface,
                             :ncControllerListGetPortInterface,
                             :length),
                            (:getuniqueid,
                             :ncControllerListGetUniqueID,
                             :length),
                            (:getdetectortype,
                             :ncControllerListGetDetectorType,
                             :length),
                            (:getfreeportinterface,
                             :ncControllerListGetFreePortInterface,
                             :getfreeportcount),
                            (:getfreeportuniqueid,
                             :ncControllerListGetFreePortUniqueID,
                             :getfreeportcount),
                            (:getpluginname,
                             :ncControllerListGetPluginName,
                             :getplugincount))
    @eval function $func(obj::ControllerList, idx::Integer)
        i = _fixindex(idx, $count(obj))
        len = ccall(($(string(symb)), libnuvu), Cint,
                    (Ptr{Void}, Cint, Ptr{Void}, Cint), obj.ptr, i, C_NULL, 0)
        buf = Array{UInt8}(len)
        _check(ccall(($(string(symb)), libnuvu), Cint,
                     (Ptr{Void}, Cint, Ptr{UInt8}, Cint), obj.ptr, i, buf, len),
               $(string(symb)))
        return _string(buf)
    end
end

for (func, symb) in ((:getportunit, :ncControllerListGetPortUnit),
                     (:getportchannel, :ncControllerListGetPortChannel))
    @eval function $func(obj::ControllerList, idx::Integer)
        i = _fixindex(idx, length(obj))
        ref = Ref{Cint}()
        _check(ccall(($(string(symb)), libnuvu), Cint,
                     (Ptr{Void}, Cint, Ptr{Cint}), obj.ptr, i, ref),
               $(string(symb)))
        return ref[]
    end
end

for (func, symb) in ((:getfullsize, :ncControllerListGetFullSizeSize),
                     (:getdetectorsize, :ncControllerListGetDetectorSize))
    @eval function $func(obj::ControllerList, idx::Integer)
        i = _fixindex(idx, length(obj))
        xref = Ref{Cint}()
        yref = Ref{Cint}()
        _check(ccall(($(string(symb)), libnuvu), Cint,
                     (Ptr{Void}, Cint, Ptr{Cint}, Ptr{Cint}),
                     obj.ptr, i, xref, yref),
               $(string(symb)))
        return (xref[], yref[])
    end
end

for (func, symb) in ((:getsize, :ncControllerListGetSize),
                     (:getfreeportcount, :ncControllerListGetFreePortCount),
                     (:getplugincount, :ncControllerListGetPluginCount))
    @eval function $func(obj::ControllerList)
        ref = Ref{Cint}()
        _check(ccall(($(string(symb)), libnuvu), Cint,
                     (Ptr{Void}, Ptr{Cint}), obj.ptr, ref),
               $(string(symb)))
        return ref[]
    end
end

for (func, symb) in ((:getfreeportunit, :ncControllerListGetFreePortUnit),
                     (:getfreeportchannel, :ncControllerListGetFreePortChannel))
    @eval function $func(obj::ControllerList, idx::Integer)
        i = _fixindex(idx, getfreeportcount(obj))
        ref = Ref{Cint}()
        _check(ccall(($(string(symb)), libnuvu), Cint,
                     (Ptr{Void}, Cint, Ptr{Cint}), obj.ptr, i, ref),
               $(string(symb)))
        return ref[]
    end
end

# faster than convert(String,buf[1:end-1])
_string(buf::Vector{UInt8}) = unsafe_string(pointer(buf))

function _fixindex(i::Integer, len::Integer)
    @assert 1 ≤ i ≤ len "out of range index"
    return convert(Cint, i - 1)
end

function _check(code::Integer, func::Union{String,Symbol})
    code == 0 || error("$func failed with code $code")
    nothing
end

#------------------------------------------------------------------------------
# CAMERA METHODS


function Camera(ctrl::ControllerList, idx::Integer, nbufs::Integer = 4)
    i = _fixindex(idx, length(ctrl))
    ref = Ref{Ptr{Void}}()
    _check(ccall((:ncCamOpenFromList, libnuvu), Cint,
                 (Ptr{Void}, Cint, Cint, Ptr{Ptr{Void}}),
                 ctrl.ptr, i, nbufs, ref),
           :ncCamOpenFromList)
    return Camera(ref[])
end

function Camera(unit::Integer, chnl::Integer, nbufs::Integer = 4)
    ref = Ref{Ptr{Void}}()
    _check(ccall((:ncCamOpen, libnuvu), Cint,
                 (Cint, Cint, Cint, Ptr{Ptr{Void}}),
                 unit, chnl, nbufs, ref),
           :ncCamOpen)
    return Camera(ref[])
end

function Base.close(cam::Camera)
    if cam.ptr != C_NULL
        ptr = cam.ptr
        cam.ptr = C_NULL
        _check(ccall((:ncCamClose, libnuvu), Cint, (Ptr{Void},), ptr),
               :ncCamClose)
    end
    return nothing
end

function _finalize(cam::Camera)
    if cam.ptr != C_NULL
        ptr = cam.ptr
        cam.ptr = C_NULL
        code = ccall((:ncCamClose, libnuvu), Cint, (Ptr{Void},), ptr)
    end
    return nothing
end

end
