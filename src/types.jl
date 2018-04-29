#
# types.jl -
#
# Types defined for Nüvü Camēras.
#

mutable struct Camera
    handle::NC.Cam # opaque handle
    function Camera(handle::NC.Cam)
        obj = new(handle)
        if handle.ptr != C_NULL
            finalizer(obj, close)
        end
        return obj
    end
end

mutable struct FrameGrabber
    handle::NC.Grab # opaque handle
    function FrameGrabber(handle::NC.Grab)
        obj = new(handle)
        if handle.ptr != C_NULL
            finalizer(obj, close)
        end
        return obj
    end
end

mutable struct ControllerList
    handle::NC.CtrlList # opaque handle
    cnt::Int
    function ControllerList(handle::NC.CtrlList)
        obj = new(handle, 0)
        if handle.ptr != C_NULL
            finalizer(obj, close)
            obj.cnt = NC.getSize(handle)
        end
        return obj
    end
end
