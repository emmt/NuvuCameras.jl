module NuvuCameras

# Low level interface.  All functions, types and constants are made available
# with the prefix `NC.`.
module NC
include("nctypes.jl")
include("ncconst.jl")
include("nccalls.jl")
end
import .NC

# Private module with stuff hidden to the end-user.  All methods, types and
# constants are made available with the prefix `Priv.`.
module Priv
include("private.jl")
end
import .Priv


# High level interface.
include("types.jl")
include("public.jl")

end
