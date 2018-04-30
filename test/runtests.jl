module NuvuCamerasTests

using NuvuCameras
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

# We first try to load the examples.
include("../examples/simpleAcquisition.jl")
include("../examples/chronologicalAcquisition.jl")
include("../examples/timedAcquisition.jl")
include("../examples/readoutModesAvailability.jl")

# write your own tests here
#@test 1 == 1

end # module
