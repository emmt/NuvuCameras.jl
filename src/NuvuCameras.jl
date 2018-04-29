module NuvuCameras

# Low level interface.  All functions, types and constants are made available
# with the prefix `NC.`.
module NC
include("nctypes.jl")
include("ncconst.jl")
include("nccalls.jl")
end
import .NC

end
