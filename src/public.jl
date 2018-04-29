#
# public.jl -
#
# Implement high-level interface to Nüvü Camēras.
#


#------------------------------------------------------------------------------
# CONTROLLER LIST METHODS

ControllerList(basic::Bool = false) =
    ControllerList(NC.open(NC.CtrlList, basic))

function Base.close(lst::ControllerList)
    lst.cnt = 0
    handle = lst.handle
    if handle.ptr != C_NULL
        lst.handle = NC.CtrlList(C_NULL)
        NC.close(handle)
    end
end

Base.length(lst::ControllerList) = lst.cnt

"""
```julia
getfreeportunit(lst, i)
```

yields the board unit for the `i`-th unused port in list of controllers `lst`.

"""
getfreeportunit

for p in (:getPortUnit, :getPortChannel, :getFreePortUnit, :getFreePortChannel,
          :getFreePortReason, :getSerial, :getModel, :getPortInterface,
          :getUniqueID, :getDetectorType, :getFreePortInterface,
          :getFreePortUniqueID, :getPluginName, :getFullSizeSize,
          :getDetectorSize)
    f = Symbol(lowercase(string(p)))
    @eval function $f(lst::ControllerList, i::Integer)
        @assert 1 ≤ i ≤ lst.cnt "out of range index"
        return NC.$p(lst.handle, i - 1)
    end
end

for p in (:getFreePortCount, :getPluginCount)
    f = Symbol(lowercase(string(p)))
    @eval $f(lst::ControllerList, i::Integer) = NC.$p(lst.handle)
end

#------------------------------------------------------------------------------
# CAMERA METHODS

Camera(unit::Integer, chnl::Integer, nbufs::Integer = 4) =
    Camera(NC.open(NC.Cam, unit, chnl, nbufs))

Camera(ctrl::ControllerList, idx::Integer, nbufs::Integer = 4) =
    Camera(NC.open(NC.Cam, ctrl.handle, idx, nbufs))

function Base.close(cam::Camera)
    handle = cam.handle
    if handle.ptr != C_NULL
        cam.handle = NC.Cam(C_NULL)
        NC.close(handle)
    end
end

#------------------------------------------------------------------------------
# FRAME GRABBER METHODS

FrameGrabber(unit::Integer, chnl::Integer, nbufs::Integer) =
    FrameGrabber(NC.open(NC.Grab, unit, chnl, nbufs))

FrameGrabber(ctrl::ControllerList, index::Integer, nbufs::Integer) =
    FrameGrabber(NC.open(NC.Grab, ctrl.handle, index, nbufs))

function Base.close(grb::FrameGrabber)
    handle = grb.handle
    if handle.ptr != C_NULL
        grb.handle = NC.Grab(C_NULL)
        NC.close(handle)
    end
end
