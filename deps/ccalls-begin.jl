#
# ccalls.jl -
#
# Calls to C-API of Nüvü Camēras.
#

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("NuvuCameras not properly installed.  Please run `Pkg.build(\"NuvuCameras\")` to create file \"",joinpath(dirname(@__FILE__),"..","deps","deps.jl"),"\"")
end
