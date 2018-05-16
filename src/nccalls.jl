#
# nccalls.jl -
#
# Calls to C functions of the Nüvü Camēras SDK.
#
# In this file, you'll find commented code (with a leading `#- `) corresponding
# to calls not yet exposed.  These parts have been automatically built from the
# definitions in `nc_api.h` by the `extract_ccalls.sed` filter and should be
# correct even though the arguments of the Julia wrapper may be adjusted to
# provide a better interface.
#
# The methods defined here directly call the C functions of the Nüvü Camēras
# SDK with some simplifications to make them easy to use (see documentation).
#
# All 337 non-deprecated functions in the Nüvü Camēras SDK are currently
# interfaced.
#

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("NuvuCameras not properly installed.  Please run `Pkg.build(\"NuvuCameras\")` to create file \"",joinpath(dirname(@__FILE__),"..","deps","deps.jl"),"\"")
end

"""
```julia
@call(func, rtype, proto, args...)
```

yields code to call C function `func` in Nüvü Camēras library assuming `rtype`
is the return type of the function, `proto` is a tuple of the argument types
and `args...` are the arguments.

If `rtype` is `Status`, the code is wrapped so that an exception
`NuvuCameraError` get thrown in case of error.

"""
macro call(func, rtype, args...)
    qfunc = QuoteNode(__symbol(func))
    expr = Expr(:call, :ccall, Expr(:tuple, qfunc, :libnuvu), rtype, args...)
    if rtype == :Status
        return quote
            local status
            status = $(esc(expr))
            if status != SUCCESS
                throw(NuvuCameraError($qfunc, status))
            end
        end
    else
        return esc(expr)
    end
end

__symbol(x::Symbol) = x
__symbol(x::AbstractString) = Symbol(x) # FIXME: check of validity of the name
function __symbol(x::Expr)
    if x.head == :quote && length(x.args) == 1
        return __symbol(x.args[1])
    end
    error("bad argument (expected a symbol, a name or a variable)")
end

"""
```julia
stringify!(v)
```

converts a vector of bytes into a Julia string.  For efficiency, the returned
string owns the vector so you must not change the vector after calling this
method.  The methods assumes that the vector has been filled using the
same convention as C and assumes that the first null byte (if any) marks the end
of the string and resize the vector accordingly.

See also: [`String`](@ref),  [`resize!`](@ref).

"""
function stringify!(buf::Vector{UInt8})
    # The `String` constructor accepts a vector of bytes (`UInt8`) to create a
    # new string which subsequently owns the vector (so you must not change it
    # as strings are supposed to be immutable in Julia).
    len = length(buf)
    @inbounds for i in 1:len
        if buf[i] == zero(UInt8)
            resize!(buf, i - 1)
            break
        end
    end
    return String(buf)
end

function fetcharray(ptr::Ptr{T}, n::Integer) where {T}
    arr = Array{T}(n)
    ccall(:memcpy, Ptr{Void}, (Ptr{T}, Ptr{T}, Csize_t), arr, ptr, sizeof(arr))
    return arr
end

# Round timeout to nearest integer.
setTimeout(handle::Union{Cam,Grab}, ms::Real) =
    setTimeout(handle, rount(Cint, ms))


function writeFileHeader(currentFile::ImageSaved, name::Name, value::Integer,
                         comment::Name)
    writeFileHeader(currentFile, INT, name, Ref{Cint}(value), comment)
end

function writeFileHeader(currentFile::ImageSaved, name::Name,
                         value::Union{AbstractFloat,Rational,Irrational},
                         comment::Name)
    writeFileHeader(currentFile, DOUBLE, name, Ref{Cdouble}(value), comment)
end

function writeFileHeader(currentFile::ImageSaved, name::Name, value::Name,
                         comment::Name)
    @call(:ncWriteFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Cstring, Cstring),
          currentFile, STRING, name, value, comment)
end

readFileHeader(currentFile::ImageSaved, dataType::HeaderDataType, name::Name) =
    readFileHeader(currentFile, Val{dataType}, name)

# int ncReadFileHeader(NcImageSaved *currentFile, enum HeaderDataType dataType,
#         const char *name, const void *value);

function readFileHeader(currentFile::ImageSaved, ::Type{Val{INT}},
                        name::Name)
    value = Ref{Cint}()
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cint}),
          currentFile, INT, name, value)
    return value[]
end

function readFileHeader(currentFile::ImageSaved, ::Type{Val{DOUBLE}},
                        name::Name)
    value = Ref{Cdouble}()
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cdouble}),
          currentFile, DOUBLE, name, value)
    return value[]
end

function readFileHeader(currentFile::ImageSaved, ::Type{Val{STRING}},
                        name::Name)
    buf = Array{Cchar}(1024) # FIXME: potential issue here
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cchar}),
          currentFile, INT, name, buf)
    return __string(pointer(buf))
end

#------------------------------------------------------------------------------
# CONTROLLER LISTING FUNCTIONS

function open(::Type{CtrlList}, basic::Bool = false)
    ctrlList = Ref{CtrlList}()
    if basic
        # int ncControllerListOpenBasic(NcCtrlList * ctrlList);
        @call(:ncControllerListOpenBasic, Status, (Ptr{CtrlList}, ), ctrlList)
    else
        # int ncControllerListOpen(NcCtrlList * ctrlList);
        @call(:ncControllerListOpen, Status, (Ptr{CtrlList}, ), ctrlList)
    end
    return ctrlList[]
end

for (m, f) in (

    # int ncControllerListGetSerial(const NcCtrlList ctrlList,
    #         int index, char* serial, int serialSize);
    (:getSerial, :ncControllerListGetSerial),

    # int ncControllerListGetModel(const NcCtrlList ctrlList,
    #         int index, char* model, int modelSize);
    (:getModel, :ncControllerListGetModel),

    # int ncControllerListGetPortInterface(const NcCtrlList ctrlList,
    #         int index, char* acqInterface, int acqInterfaceSize);
    (:getPortInterface, :ncControllerListGetPortInterface),

    # int ncControllerListGetUniqueID(const NcCtrlList ctrlList,
    #         int index, char* uniqueID, int uniqueIDSize);
    (:getUniqueID, :ncControllerListGetUniqueID),

    # int ncControllerListGetDetectorType(const NcCtrlList ctrlList,
    #         int index, char* detectorType, int detectorTypeSize);
    (:getDetectorType, :ncControllerListGetDetectorType),

    # int ncControllerListGetFreePortInterface(const NcCtrlList ctrlList,
    #         int index, char* acqInterface, int acqInterfaceSize);
    (:getFreePortInterface, :ncControllerListGetFreePortInterface),

    # int ncControllerListGetFreePortUniqueID(const NcCtrlList ctrlList,
    #         int index, char* uniqueID, int uniqueIDSize);
    (:getFreePortUniqueID, :ncControllerListGetFreePortUniqueID),

    # int ncControllerListGetPluginName(const NcCtrlList ctrlList,
    #         int index, char* pluginName, int pluginNameSize);
    (:getPluginName, :ncControllerListGetPluginName))

    qf = QuoteNode(f)

    @eval function $m(ctrlList::CtrlList, index::Integer)
        # Fisrt call to retrieve the number of bytes, then second call to
        # retrieve the contents.
        nbytes = @call($f, Cint, (CtrlList, Cint, Ptr{Void}, Cint),
                       ctrlList, index, C_NULL, 0)
        if nbytes < 1
            # Assume index was out of bound.
            throw(NuvuCameraError($qf, ERROR_OUT_OF_BOUNDS))
        end
        buf = Array{UInt8}(nbytes)
        status = Status(@call($f, Cint, (CtrlList, Cint, Ptr{UInt8}, Cint),
                              ctrlList, index, buf, nbytes))
        if status != SUCCESS
            throw(NuvuCameraError($qf, status))
        end
        return stringify!(buf)
    end

end


#------------------------------------------------------------------------------
# FRAME GRABBER FUNCTIONS

setOpenMacAddress(::Type{Grab}, macAddress::Name) =
    # int ncGrabSetOpenMacAdress(char* macAddress);
    @call(:ncGrabSetOpenMacAdress, Status, (Cstring, ), macAddress)

function open(::Type{Grab}, unit::Integer, channel::Integer,
              nbrBuffer::Integer)
    grab = Ref{Grab}()
    # int ncGrabOpen(int unit, int channel, int nbrBuffer, NcGrab* grab);
    @call(:ncGrabOpen, Status, (Cint, Cint, Cint, Ptr{Grab}),
          unit, channel, nbrBuffer, grab)
    return grab[]
end

function open(::Type{Grab}, ctrlList::CtrlList, index::Integer,
              nbrBuffer::Integer)
    grab = Ref{Grab}()
    # int ncGrabOpenFromList(const NcCtrlList ctrlList, int index,
    #         int nbrBuffer, NcGrab* grab);
    @call(:ncGrabOpenFromList, Status, (CtrlList, Cint, Cint, Ptr{Grab}),
          ctrlList, index, nbrBuffer, grab)
    return grab[]
end

function open(::Type{ImageParams{Grab}})
    value = Ref{ImageParams{Grab}}()
    # int ncGrabOpenImageParams(ImageParams *imageParams);
    @call(:ncGrabOpenImageParams, Status, (Ptr{ImageParams}, ), value)
    return value[]
end

function saveImage(grab::Grab, image::Ptr{T}, name::Name,
                   saveFormat::ImageFormat,
                   overwrite::Bool) where {T<:Union{UInt32,UInt64,Cfloat}}
    saveImage(grab, Ptr{Void}(image), name, saveFormat, getPixelType(T),
              overwrite)
end

function saveImage(grab::Grab, image::DenseMatrix{<:PixelTypes}, name::Name,
                   saveFormat::ImageFormat, overwrite::Bool)
    saveImage(grab, pointer(image), name, saveFormat, overwrite)
end

"""
```julia
NC.isParamAvailable(handle, param, setting) -> boolean
```

yields whether parameter `param`, possibly with value `setting`, is available
for acquisition device `handle`.

""" isParamAvailable

for (m, H, f) in (
    # int ncGrabParamAvailable(NcGrab grab, enum Features param, int setting);
    (:isParamAvailable, Grab, :ncGrabParamAvailable),

    # int ncCamParamAvailable(NcCam cam, enum Features param, int setting);
    (:isParamAvailable, Cam, :ncCamParamAvailable))

    @eval $m(handle::$H, param::Features, setting::Integer) =
        (@call(:ncCamParamAvailable, Cint, ($H, Features, Cint),
               handle, param, setting) == SUCCESS.code)

end

#------------------------------------------------------------------------------
# CAMERA FUNCTIONS

setOpenMacAddress(::Type{Cam}, macAddress::Name) =
    # int ncCamSetOpenMacAdress(char* macAddress);
    @call(:ncCamSetOpenMacAdress, Status, (Cstring, ), macAddress)

"""
```julia
open(::Type{Cam}, unit, channel, nbufs) -> cam
```
"""
function open(::Type{Cam}, unit::Integer, channel::Integer, nbrBuffer::Integer)
    cam = Ref{Cam}()
    # int ncCamOpen(int unit, int channel, int nbrBuffer, NcCam* cam);
    @call(:ncCamOpen, Status, (Cint, Cint, Cint, Ptr{Cam}),
          unit, channel, nbrBuffer, cam)
    return cam[]
end

function open(::Type{Cam}, ctrlList::CtrlList, index::Integer,
              nbrBuffer::Integer)
    cam = Ref{Cam}()
    # int ncCamOpenFromList(const NcCtrlList ctrlList, int index, int nbrBuffer, NcCam* cam);
    @call(:ncCamOpenFromList, Status, (CtrlList, Cint, Cint, Ptr{Cam}),
          ctrlList, index, nbrBuffer, cam)
    return cam[]
end

"""
```julia
getHeartbeat(cam) -> ms
```
""" getHeartbeat


function saveImage(width::Integer, height::Integer, imageParams::ImageParams,
                   image::Ptr{Void}, dataType::ImageDataType, saveName::Name,
                   saveFormat::ImageFormat, compress::ImageCompression,
                   addComments::Name, overwrite::Bool)
    # int ncSaveImage(int width, int height, ImageParams imageParams,
    #         const void* image, enum ImageDataType dataType,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         enum ImageCompression compress, const char* addComments,
    #         int overwriteFlag);
    @call(:ncSaveImage, Status,
          (Cint, Cint, ImageParams, Ptr{Void}, ImageDataType, Cstring,
           ImageFormat, ImageCompression, Cstring, Cint),
          width, height, imageParams, imageNc, dataType, saveName, saveFormat,
          compress, addComments, overwriteFlag)
end

function open(::Type{ImageParams{Cam}})
    value = Ref{ImageParams{Cam}}()
    # int ncCamOpenImageParams(ImageParams *imageParams);
    @call(:ncCamOpenImageParams, Status, (Ptr{ImageParams}, ), value)
    return value[]
end



for (jf1, cf1, jf2, cf2, T) in (

    # int ncCamAllocUInt32Image(NcCam cam, uint32_t **image);
    # int ncCamFreeUInt32Image(uint32_t **image);
    (:allocImage, :ncCamAllocUInt32Image, :freeImage, :ncCamFreeUInt32Image,
     UInt32),

    # FIXME: These functions are not in the C header but are documented.
    # int ncCamAllocFloatImage(NcCam cam, uint32_t **image);
    # int ncCamFreeFloatImage(uint32_t **image);
    (:allocImage, :ncCamAllocFloatImage, :freeImage, :ncCamFreeFloatImage,
     Cfloat))

    @eval begin

        function $jf1(::Type{$T}, cam::Cam)
            buf = Ref{Ptr{$T}}(0)
            @call($cf1, Status, (Cam, Ptr{Ptr{$T}}), cam, buf)
            return buf[]
        end

        function $jf2(ptr::Ptr{$T})
            buf = Ref{Ptr{$T}}(ptr)
            @call($cf2, Status, (Ptr{Ptr{$T}}, ), buf)
        end

    end
end

"""
```julia
getOverrun(cam) -> ovr
```
""" getOverrun

function saveImage(cam::Cam, image::Ptr{T}, name::Name,
                   saveFormat::ImageFormat, comments::Name,
                   overwrite::Bool) where {T<:Union{UInt64}}
    saveImage(cam, Ptr{Void}(image), name, saveFormat, getPixelType(T),
              comments, overwrite)
end

function saveImage(cam::Cam, image::DenseMatrix{<:PixelTypes}, name::Name,
                   saveFormat::ImageFormat, comments::Name, overwrite::Bool)
    saveImage(cam, pointer(image), name, saveFormat, comments, overwrite)
end

#------------------------------------------------------------------------------
# TIMESTAMP FUNCTIONS

function setTimestampInternal(handle::Union{Cam,Grab}, dateTime::TmStruct,
                              nbrUs::Integer)
    setTimestampInternal(handle, Ref(dateTime), nbrUs)
end

function getCtrlTimestamp(handle::Union{Cam,Grab}, imageAcqu::Ptr{Image})
    ctrTimestamp = Ref{TmStruct}()
    return getCtrlTimestamp(handle, imageAcqu, ctrTimestamp)
end

#------------------------------------------------------------------------------

# FIXME: check code
for (m, H, f) in (
    # int ncGrabGetVersion(NcGrab grab, enum VersionType versionType,
    #         char* version, int bufferSize);
    (:getVersion, Grab, :ncGrabGetVersion),

    # int ncCamGetVersion(NcCam cam, enum VersionType versionType,
    #         char* version, int bufferSize);
    (:getVersion, Cam, :ncCamGetVersion),
)
    @eval function $m(handle::$H, versionType::VersionType)
        buf = Array{UInt8}(256)
        @call($f, Status,
              ($H, VersionType, Ptr{UInt8}, Cint),
              handle, versionType, buf, sizeof(buf) - 1)
        return stringify!(buf)
    end
end

function getSerialNumber(cam::Cam)
    buf = Array{UInt8}(64) # FIXME: the doc. says 32 is enough...
    # int ncCamGetSerialNumber(NcCam cam, char *sn);
    @call(:ncCamGetSerialNumber, Status, (Cam, Ptr{UInt8}), cam, buf)
    return stringify!(buf)
end

"""
```julia
getCurrentReadoutMode(cam) -> numb, amptyp, ampstr, vfreq, hfreq
```

yields the current readout mode of camera `cam`.  Returned values are the
readout mode number `numb`, the amplifier type `amptyp` (`Ampli`), its name
`ampstr` and the corresponding vertical and horizontal frequencies `vfreq`, and
`hfreq`.

"""
function getCurrentReadoutMode(cam::Cam)
    readoutMode = Ref{Cint}()
    ampliType = Ref{Ampli}()
    ampliString = Array{UInt8}(32) # see the examples...
    vertFreq = Ref{Cint}()
    horizFreq = Ref{Cint}()
    # int ncCamGetCurrentReadoutMode(NcCam cam, int* readoutMode,
    #         enum Ampli* ampliType, char* ampliString, int *vertFreq,
    #         int *horizFreq);
    @call(:ncCamGetCurrentReadoutMode, Status,
          (Cam, Ptr{Cint}, Ptr{Ampli}, Ptr{UInt8}, Ptr{Cint}, Ptr{Cint}),
          cam, readoutMode, ampliType, ampliString, vertFreq, horizFreq)
    return (readoutMode[], ampliType[], stringify!(ampliString),
            vertFreq[], horizFreq[])
end

"""
```julia
getReadoutMode(cam, i) -> amptyp, ampstr, vfreq, hfreq
```

yields the `i`-th readout mode of camera `cam`.  Returned values are the
amplifier type `amptyp` (`Ampli`), its name `ampstr` and the corresponding
vertical and horizontal frequencies `vfreq`, and `hfreq`.

"""
function getReadoutMode(cam::Cam, number::Integer)
    # int ncCamGetReadoutMode(NcCam cam, int number, enum Ampli* ampliType,
    #         char* ampliString, int *vertFreq, int *horizFreq);
    ampliType = Ref{Ampli}()
    ampliString = Array{UInt8}(32) # see the examples...
    vertFreq = Ref{Cint}()
    horizFreq = Ref{Cint}()
    @call(:ncCamGetReadoutMode, Status,
          (Cam, Cint, Ptr{Ampli}, Ptr{UInt8}, Ptr{Cint}, Ptr{Cint}),
          cam, number, ampliType, ampliString, vertFreq, horizFreq)
    return (ampliType[], stringify!(ampliString), vertFreq[], horizFreq[])
end

# FIXME: undocumented
function getDetectorTypeName(detectorType::DetectorType)
    str = Ref{Ptr{Cchar}}()
    # int ncCamDetectorTypeEnumToString(enum DetectorType detectorType, const char** str);
    @call(:ncCamDetectorTypeEnumToString, Status,
          (DetectorType, Ptr{Ptr{Cchar}}), detectorType, str)
    return unsafe_string(str[])
end

#------------------------------------------------------------------------------
# CALLBACKS

for (m, H, f) in (

    # Frame grabber callbacks.

    # int ncGrabSetEvent(NcGrab grab, NcCallbackFunc funcName, void* ncData);
    (:setEvent, Grab, :ncGrabSetEvent),

    # int ncGrabSaveImageSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setWriteHeaderCallback, Grab, :ncGrabSaveImageSetHeaderCallback),

    # int ncGrabSaveImageWriteCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
    (:setWriteImageCallback, Grab, :ncGrabSaveImageWriteCallback),

    # int ncGrabSaveImageCloseCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int fileNo, void *data), void *data);
    (:setCloseImageCallback, Grab, :ncGrabSaveImageCloseCallback),

    # int ncGrabSaveParamSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setSaveParamHeaderCallback, Grab, :ncGrabSaveParamSetHeaderCallback),

    # int ncGrabLoadParamSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setLoadParamHeaderCallback, Grab, :ncGrabLoadParamSetHeaderCallback),

    # int ncGrabCreateBiasNewImageCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
    (:setCreateBiasCallback, Grab, :ncGrabCreateBiasNewImageCallback),


    # Camera callbacks.

    # int ncCamSetEvent(NcCam cam, NcCallbackFunc funcName, void *ncData);
    (:setEvent, Cam, :ncCamSetEvent),

    # int ncCamReadyToClose(NcCam cam, void (*fct)(NcCam cam, void *data),
    #         void *data);
    (:readyToClose, Cam, :ncCamReadyToClose),

    # int ncCamSaveImageSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcCam cam, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setWriteHeaderCallback, Cam, :ncCamSaveImageSetHeaderCallback),

    # int ncCamSaveImageWriteCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int imageNo, void *data), void *data);
    (:setWriteImageCallback, Cam, :ncCamSaveImageWriteCallback),

    # int ncCamSaveImageCloseCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int fileNo, void *data), void *data);
    (:setCloseImageCallback, Cam, :ncCamSaveImageCloseCallback),

    # int ncCamSaveParamSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setSaveParamHeaderCallback, Cam, :ncCamSaveParamSetHeaderCallback),

    # int ncCamLoadParamSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setLoadParamHeaderCallback, Cam, :ncCamLoadParamSetHeaderCallback),

    # int ncCamCreateBiasNewImageCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int imageNo, void *data), void *data);
    (:setCreateBiasCallback, Cam, :ncCamCreateBiasNewImageCallback),

    # int ncCamSetOnStatusAlertCallback(NcCam cam,
    #         void (*fct)(NcCam cam, void* data, int errorCode,
    #                     const char* errorString), void* data);
    (:setOnStatusAlertCallback, Cam, :ncCamSetOnStatusAlertCallback),

    # int ncCamSetOnStatusUpdateCallback(NcCam cam,
    #         void (*fct)(NcCam cam, void* data), void* data);
    (:setOnStatusUpdateCallback, Cam, :ncCamSetOnStatusUpdateCallback),


    # Processing callbacks.

    # int ncProcSaveSetHeaderCallback(NcProc ctx,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setSaveHeaderCallback, Proc, :ncProcSaveSetHeaderCallback),

    # int ncProcLoadSetHeaderCallback(NcProc ctx,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (:setLoadHeaderCallback, Proc, :ncProcLoadSetHeaderCallback))

    @eval $m(handle::$H, fct::Ptr{Void}, data::Ptr{Void}) =
        @call($f, Status, ($H, Ptr{Void}, Ptr{Void}), handle, fct, data)

end

#------------------------------------------------------------------------------
# CROP MODE SOLUTIONS

function setCropMode(cam::Cam, mode::CropMode, paddingPixelsMinimumX::Integer,
                     paddingPixelsMinimumY::Integer)
    # int ncCamSetCropMode(NcCam cam, enum CropMode mode,
    #         int paddingPixelsMinimumX,
    #         int paddingPixelsMinimumY);
    @call(:ncCamSetCropMode, Status, (Cam, CropMode, Cint, Cint),
          cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)
end

function getCropMode(cam::Cam)
    mode = Ref{CropMode}()
    paddingPixelsMinimumX = Ref{Cint}()
    paddingPixelsMinimumY = Ref{Cint}()
    figureOfMerit = Ref{Cfloat}()
    # int ncCamGetCropMode(NcCam cam, enum CropMode* mode,
    #         int* paddingPixelsMinimumX,
    #         int* paddingPixelsMinimumY,
    #         float* figureOfMerit);
    @call(:ncCamGetCropMode, Status,
          (Cam, Ptr{CropMode}, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}),
          cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY,
          figureOfMerit)
    return (mode[], paddingPixelsMinimumX[], paddingPixelsMinimumY[],
            figureOfMerit[])
end

function open(::Type{CropModeSolutions}, cropWidth::Integer,
              cropHeight::Integer, mode::CropMode,
              paddingPixelsMinimumX::Integer, paddingPixelsMinimumY::Integer,
              cam::Cam)
    solutionSet = Ref{CropModeSolutions}()
    # int ncCropModeSolutionsOpen(NcCropModeSolutions* solutionSet,
    #         int cropWidth, int cropHeight,
    #         enum CropMode mode, int paddingPixelsMinimumX,
    #         int paddingPixelsMinimumY, NcCam cam);
    @call(:ncCropModeSolutionsOpen, Status,
          (Ptr{CropModeSolutions}, Cint, Cint, CropMode, Cint, Cint, Cam),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX,
          paddingPixelsMinimumY, cam)
    return solutionSet[]
end

refresh(solutionSet::CropModeSolutions) =
    # int ncCropModeSolutionsRefresh(NcCropModeSolutions solutionSet);
    @call(:ncCropModeSolutionsRefresh, Status,
          (CropModeSolutions, ), solutionSet)

function setParameters(solutionSet::CropModeSolutions, cropWidth::Integer,
                       cropHeight::Integer, mode::CropMode,
                       paddingPixelsMinimumX::Integer,
                       paddingPixelsMinimumY::Integer)
    # int ncCropModeSolutionsSetParameters(NcCropModeSolutions solutionSet,
    #         int cropWidth, int cropHeight,
    #         enum CropMode mode,
    #         int paddingPixelsMinimumX,
    #         int paddingPixelsMinimumY);
    @call(:ncCropModeSolutionsSetParameters, Status,
          (CropModeSolutions, Cint, Cint, CropMode, Cint, Cint),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX,
          paddingPixelsMinimumY)
end

function getParameters(solutionSet::CropModeSolutions)
    cropWidth = Ref{Cint}()
    cropHeight = Ref{Cint}()
    mode = Ref{CropMode}()
    paddingPixelsMinimumX = Ref{Cint}()
    paddingPixelsMinimumY = Ref{Cint}()
    # int ncCropModeSolutionsGetParameters(NcCropModeSolutions solutionSet,
    #         int* cropWidth, int* cropHeight,
    #         enum CropMode* mode,
    #         int* paddingPixelsMinimumX,
    #         int* paddingPixelsMinimumY);
    @call(:ncCropModeSolutionsGetParameters, Status,
          (CropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{CropMode},
           Ptr{Cint}, Ptr{Cint}),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX,
          paddingPixelsMinimumY)
    return (cropWidth[], cropHeight[], mode[], paddingPixelsMinimumX[],
            paddingPixelsMinimumY[])
end

function getTotal(solutionSet::CropModeSolutions)
    totalNbrSolutions = Ref{Cint}()
    # int ncCropModeSolutionsGetTotal(NcCropModeSolutions solutionSet,
    #         int* totalNbrSolutions);
    @call(:ncCropModeSolutionsGetTotal, Status,
          (CropModeSolutions, Ptr{Cint}), solutionSet, totalNbrSolutions)
    return totalNbrSolutions[]
end

function getResult(solutionSet::CropModeSolutions, solutionIndex::Integer)
    figureOfMerit = Ref{Cfloat}()
    startX_min = Ref{Cint}()
    startX_max = Ref{Cint}()
    startY_min = Ref{Cint}()
    startY_max = Ref{Cint}()
    # int ncCropModeSolutionsGetResult(NcCropModeSolutions solutionSet,
    #         unsigned int solutionIndex,
    #         float* figureOfMerit,
    #         int* startX_min, int* startX_max,
    #         int* startY_min, int* startY_max);
    @call(:ncCropModeSolutionsGetResult, Status,
          (CropModeSolutions, Cuint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint},
           Ptr{Cint}, Ptr{Cint}),
          solutionSet, solutionIndex, figureOfMerit, startX_min, startX_max,
          startY_min, startY_max)
    return (figureOfMerit[], startX_min[], startX_max[],
            startY_min[], startY_max[])
end

function getLocationRanges(solutionSet::CropModeSolutions)
    offsetX_min = Ref{Cint}()
    offsetX_max = Ref{Cint}()
    offsetY_min = Ref{Cint}()
    offsetY_max = Ref{Cint}()
    # int ncCropModeSolutionsGetLocationRanges(NcCropModeSolutions solutionSet,
    #         int *offsetX_min,
    #         int *offsetX_max,
    #         int *offsetY_min,
    #         int *offsetY_max);
    @call(:ncCropModeSolutionsGetLocationRanges, Status,
          (CropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          solutionSet, offsetX_min, offsetX_max, offsetY_min, offsetY_max)
    return (offsetX_min[], offsetX_max[], offsetY_min[], offsetY_max[])
end

function getResultAtLocation(solutionSet::CropModeSolutions,
                             offsetX::Integer, offsetY::Integer)
    figureOfMerit = Ref{Cfloat}()
    startX_min = Ref{Cint}()
    startX_max = Ref{Cint}()
    startY_min = Ref{Cint}()
    startY_max = Ref{Cint}()
    # int ncCropModeSolutionsGetResultAtLocation(NcCropModeSolutions solutionSet,
    #         int offsetX, int offsetY,
    #         float *figureOfMerit,
    #         int *startX_min, int *startX_max,
    #         int *startY_min, int *startY_max);
    @call(:ncCropModeSolutionsGetResultAtLocation, Status,
          (CropModeSolutions, Cint, Cint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint},
           Ptr{Cint}, Ptr{Cint}),
          solutionSet, offsetX, offsetY, figureOfMerit, startX_min, startX_max,
          startY_min, startY_max)
    return (figureOfMerit[], startX_min[], startX_max[],
            startY_min[], startY_max[])
end


#------------------------------------------------------------------------------
# COMMON METHODS

#
# Methods which just take a handle argument.
#
# `m` is the Julia method, `H` is the handle type, `f` is the C function to
# call.
#
for (m, H, f) in (

    # int ncGrabAbort(NcGrab grab);
    (:abort, Grab, :ncGrabAbort),

    # int ncCamAbort(NcCam cam);
    (:abort, Cam, :ncCamAbort),

    # int ncCamMRoiApply(NcCam cam);
    (:applyMRoi, Cam, :ncCamMRoiApply),

    # int ncCamBeginAcquisition(NcCam cam);
    (:beginAcquisition, Cam, :ncCamBeginAcquisition),

    # int ncGrabCancelBiasCreation(NcGrab grab);
    (:cancelBiasCreation, Grab, :ncGrabCancelBiasCreation),

    # int ncCamCancelBiasCreation(NcCam cam);
    (:cancelBiasCreation, Cam, :ncCamCancelBiasCreation),

    # int ncGrabCancelEvent(NcGrab grab);
    (:cancelEvent, Grab, :ncGrabCancelEvent),

    # int ncCamCancelEvent(NcCam cam);
    (:cancelEvent, Cam, :ncCamCancelEvent),

    # int ncGrabClose(NcGrab grab);
    (:close, Grab, :ncGrabClose),

    # int ncCamClose(NcCam cam);
    (:close, Cam, :ncCamClose),

    # int ncGrabCloseImageParams(ImageParams imageParams);
    (:close, ImageParams{Grab}, :ncGrabCloseImageParams),

    # int ncCamCloseImageParams(ImageParams imageParams);
    (:close, ImageParams{Cam}, :ncCamCloseImageParams),

    # int ncCropModeSolutionsClose(NcCropModeSolutions solutionSet);
    (:close, CropModeSolutions, :ncCropModeSolutionsClose),

    # int ncProcClose(NcProc ctx);
    (:close, Proc, :ncProcClose),

    # int ncStatsClose(NcStatsCtx *statsCtx);
    (:close, StatsCtx, :ncStatsClose),

    # int ncControllerListFree(NcCtrlList ctrlList);
    (:close, CtrlList, :ncControllerListFree),

    # int ncProcComputeBias(NcProc ctx);
    (:computeBias, Proc, :ncProcComputeBias),

    # int ncProcEmptyStack(NcProc ctx);
    (:emptyStack, Proc, :ncProcEmptyStack),

    # int ncGrabFlushReadQueues(NcGrab grab);
    (:flushReadQueues, Grab, :ncGrabFlushReadQueues),

    # int ncCamFlushReadQueues(NcCam cam);
    (:flushReadQueues, Cam, :ncCamFlushReadQueues),

    # int ncCamMRoiRollback(NcCam cam);
    (:rollbackMRoi, Cam, :ncCamMRoiRollback),

    # int ncGrabStopSaveAcquisition(NcGrab grab);
    (:stopSaveAcquisition, Grab, :ncGrabStopSaveAcquisition),

    # int ncCamStopSaveAcquisition(NcCam cam);
    (:stopSaveAcquisition, Cam, :ncCamStopSaveAcquisition))

    @eval $m(handle::$H) = @call($f, Status, ($H, ), handle)

end

#
# Methods which retrieve 1 parameter.
#
# `m` is the Julia method, `H` is the handle type, `f` is the C function to
# call, `T` is the C type of the retrieved value.
#
# If `T` is `Bool`, then a `Cint` is retrieved and a boolean result is
# returned.
#
for (m, H, f, T) in (

    # int ncCamMRoiCanApplyWithoutStop(NcCam cam, int* nonStop);
    (:canApplyWithoutStop, Cam, :ncCamMRoiCanApplyWithoutStop, Bool),

    # int ncProcGetBiasClampLevel(NcProc ctx, int* biasLevel);
    (:getBiasClampLevel, Proc, :ncProcGetBiasClampLevel, Cint),

    # int ncCamGetDetectorTemp(NcCam cam, double* detectorTemp);
    (:getDetectorTemp, Cam, :ncCamGetDetectorTemp, Cdouble),

    # int ncCamGetDetectorType(NcCam cam, enum DetectorType *type);
    (:getDetectorType, Cam, :ncCamGetDetectorType, DetectorType),

    # int ncImageGetFileFormat(NcImageSaved* image, enum ImageFormat* format);
    (:getFileFormat, ImageSaved, :ncImageGetFileFormat, ImageFormat),

    # int ncCamGetFrameLatency(NcCam cam, int *frameLatency);
    (:getFrameLatency, Cam, :ncCamGetFrameLatency, Cint),

    # int ncControllerListGetFreePortCount(const NcCtrlList ctrlList,
    #         int * portCount);
    (:getFreePortCount, CtrlList, :ncControllerListGetFreePortCount, Cint),

    # int ncGrabGetHeartbeat(NcGrab grab, int *timeMs);
    (:getHeartbeat, Grab, :ncGrabGetHeartbeat, Cint),

    # int ncCamGetHeartbeat(NcCam cam, int *timeMs);
    (:getHeartbeat, Cam, :ncCamGetHeartbeat, Cint),

    # int ncProcGetImage(NcProc ctx, NcImage** image);
    (:getImage, Proc, :ncProcGetImage, Ptr{Image}),

    # int ncCamGetMRoiCount(NcCam cam, int * count);
    (:getMRoiCount, Cam, :ncCamGetMRoiCount, Cint),

    # int ncCamMRoiHasChanges(NcCam cam, int* hasChanges);
    (:getMRoiHasChanges, Cam, :ncCamMRoiHasChanges, Bool),

    # int ncCamGetMRoiRegionCount(ImageParams params, int * count);
    (:getMRoiRegionCount, ImageParams, :ncCamGetMRoiRegionCount, Cint),

    # int ncCamGetMRoiCountMax(NcCam cam, int * count);
    (:getMRoiCountMax, Cam, :ncCamGetMRoiCountMax, Cint),

    # int ncGrabGetNbrDroppedImages(NcGrab grab, int* nbrDroppedImages);
    (:getNbrDroppedImages, Grab, :ncGrabGetNbrDroppedImages, Cint),

    # int ncCamGetNbrDroppedImages(NcCam cam, int* nbrDroppedImages);
    (:getNbrDroppedImages, Cam, :ncCamGetNbrDroppedImages, Cint),

    # int ncCamGetNbrReadoutModes(NcCam cam, int* nbrReadoutMode);
    (:getNbrReadoutModes, Cam, :ncCamGetNbrReadoutModes, Cint),

    # int ncGrabGetNbrTimeout(NcGrab grab, int* nbrTimeout);
    (:getNbrTimeout, Grab, :ncGrabGetNbrTimeout, Cint),

    # int ncCamGetNbrTimeout(NcCam cam, int* nbrTimeout);
    (:getNbrTimeout, Cam, :ncCamGetNbrTimeout, Cint),

    # int ncGrabGetOverrun(NcGrab grab, int* overrunOccurred);
    (:getOverrun, Grab, :ncGrabGetOverrun, Bool),

    # int ncCamGetOverrun(NcCam cam, int* overrunOccurred);
    (:getOverrun, Cam, :ncCamGetOverrun, Bool),

    # int ncCamGetOverscanLines(NcCam cam, int *overscanLines);
    (:getOverscanLines, Cam, :ncCamGetOverscanLines, Cint),

    # int ncProcGetOverscanLines(NcProc ctx, int *overscanLines);
    (:getOverscanLines, Proc, :ncProcGetOverscanLines, Cint),

    # int ncControllerListGetPluginCount(const NcCtrlList ctrlList,
    #         int * listSize);
    (:getPluginCount, CtrlList, :ncControllerListGetPluginCount, Cint),

    # int ncProcGetProcType(NcProc ctx, int *type);
    (:getProcType, Proc, :ncProcGetProcType, Cint),

    # int ncCamGetReadoutTime(NcCam cam, double *time);
    (:getReadoutTime, Cam, :ncCamGetReadoutTime, Cdouble),

    # int ncGrabSaveImageGetCompressionType(NcGrab grab,
    #         enum ImageCompression *compress);
    (:getCompressionType, Grab,
     :ncGrabSaveImageGetCompressionType, ImageCompression),

    # int ncCamSaveImageGetCompressionType(NcCam cam,
    #         enum ImageCompression *compress);
    (:getCompressionType, Cam,
     :ncCamSaveImageGetCompressionType, ImageCompression),

    # int ncGrabGetSerialTimeout(NcGrab grab, int *serialTimeout);
    (:getSerialTimeout, Grab, :ncGrabGetSerialTimeout, Cint),

    # int ncGrabGetSerialUnreadBytes(NcGrab grab, int* numByte);
    (:getSerialUnreadBytes, Grab, :ncGrabGetSerialUnreadBytes, Cint),

    # int ncControllerListGetSize(const NcCtrlList ctrlList, int * listSize);
    (:getSize, CtrlList, :ncControllerListGetSize, Cint),

    # int ncCamGetStatusPollRate(NcCam cam, int * periodMs);
    (:getStatusPollRate, Cam, :ncCamGetStatusPollRate, Cint),

    # int ncGrabGetTimeout(NcGrab grab, int* timeTimeout);
    (:getTimeout, Grab, :ncGrabGetTimeout, Cint),

    # int ncCamGetTimeout(NcCam cam, int* timeTimeout);
    (:getTimeout, Cam, :ncCamGetTimeout, Cint),

    # int ncGrabNbrImagesAcquired(NcGrab grab, int *nbrImages);
    (:nbrImagesAcquired, Grab, :ncGrabNbrImagesAcquired, Cint),

    # int ncCamNbrImagesAcquired(NcCam cam, int *nbrImages);
    (:nbrImagesAcquired, Cam, :ncCamNbrImagesAcquired, Cint),

    # int ncGrabRead(NcGrab grab, NcImage** imageAcqu);
    (:read, Grab, :ncGrabRead, Ptr{Image}),

    # int ncCamRead(NcCam cam, NcImage** imageAcqu);
    (:read, Cam, :ncCamRead, Ptr{Image}))

    if T == Bool
        @eval function $m(handle::$H)
            out = Ref{Cint}()
            @call($f, Status, ($H, Ptr{$T}), handle, out)
            return (out[] != zero(Cint))
        end
    else
        @eval function $m(handle::$H)
            out = Ref{$T}()
            @call($f, Status, ($H, Ptr{$T}), handle, out)
            return out[]
        end
    end
end

#
# Methods which retrieve 2 parameters.
#
# `m` is the Julia method, `H` is the handle type, `f` is the C function to
# call, `T1` and `T2` are the C types of the retrieved values.
#
# It the type of the last output argument is `Bool`, then a `Cint` is retrieved
# and a boolean value is returned.
#
for (m, H, f, T1, T2) in (

    # int ncCamGetActiveRegion(NcCam cam, int *width, int *height);
    (:getActiveRegion, Cam, :ncCamGetActiveRegion, Cint, Cint),

    # int ncCamGetAnalogGainRange(NcCam cam, int* analogGainMin,
    #         int* analogGainMax);
    (:getAnalogGainRange, Cam, :ncCamGetAnalogGainRange, Cint, Cint),

    # int ncCamGetAnalogOffsetRange(NcCam cam, int* analogOffsetMin,
    #         int* analogOffsetMax);
    (:getAnalogOffsetRange, Cam, :ncCamGetAnalogOffsetRange, Cint, Cint),

    # int ncCamGetBinningMode(NcCam cam, int *binXValue, int *binYValue);
    (:getBinningMode, Cam, :ncCamGetBinningMode, Cint, Cint),

    # int ncCamGetCalibratedEmGainRange(NcCam cam, int* calibratedEmGainMin,
    #         int* calibratedEmGainMax);
    (:getCalibratedEmGainRange, Cam,
     :ncCamGetCalibratedEmGainRange, Cint, Cint),

    # int ncCamGetCalibratedEmGainTempRange(NcCam cam,
    #         double* calibratedEmGainTempMin,
    #         double* calibratedEmGainTempMax);
    (:getCalibratedEmGainTempRange, Cam,
     :ncCamGetCalibratedEmGainTempRange, Cdouble, Cdouble),

    # int ncCamGetFullCCDSize(NcCam cam, int *width, int *height);
    (:getFullCCDSize, Cam, :ncCamGetFullCCDSize, Cint, Cint),

    # int ncCamGetMaxSize(NcCam cam, int *width, int *height);
    (:getMaxSize, Cam, :ncCamGetMaxSize, Cint, Cint),

    # int ncGrabGetProcType(NcGrab grab, int * type, int * nbrImagesPc);
    (:getProcType, Grab, :ncGrabGetProcType, Cint, Cint),

    # int ncCamGetProcType(NcCam cam, int * type, int * nbrImagesPc);
    (:getProcType, Cam, :ncCamGetProcType, Cint, Cint),

    # int ncCamGetRawEmGainRange(NcCam cam, int* rawEmGainMin,
    #         int* rawEmGainMax);
    (:getRawEmGainRange, Cam, :ncCamGetRawEmGainRange, Cint, Cint),

    # int ncCamGetSafeShutdownTemperature(NcCam cam, double *safeTemperature,
    #         int *dontCare);
    (:getSafeShutdownTemperature, Cam,
     :ncCamGetSafeShutdownTemperature, Cdouble, Bool),

    # int ncGrabGetSize(NcGrab grab, int* width, int* height);
    (:getSize, Grab, :ncGrabGetSize, Cint, Cint),

    # int ncCamGetSize(NcCam cam, int *width, int *height);
    (:getSize, Cam, :ncCamGetSize, Cint, Cint),

    # int ncCamGetTargetDetectorTempRange(NcCam cam,
    #         double *targetDetectorTempMin, double *targetDetectorTempMax);
    (:getTargetDetectorTempRange, Cam,
     :ncCamGetTargetDetectorTempRange, Cdouble, Cdouble),

    # int ncGrabReadChronological(NcGrab grab, NcImage** imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronological, Grab, :ncGrabReadChronological, Ptr{Image}, Cint),

    # int ncCamReadChronological(NcCam cam, NcImage** imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronological, Cam, :ncCamReadChronological, Ptr{Image}, Cint),

    # int ncGrabReadChronologicalNonBlocking(NcGrab grab, NcImage** imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, Grab,
     :ncGrabReadChronologicalNonBlocking, Ptr{Image}, Cint),

    # int ncCamReadChronologicalNonBlocking(NcCam cam, NcImage **imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, Cam,
     :ncCamReadChronologicalNonBlocking, Ptr{Image}, Cint))

    if T2 == Bool
        @eval function $m(handle::$H)
            out1 = Ref{$T1}()
            out2 = Ref{Cint}()
            @call($f, Status, ($H, Ptr{$T1}, Ptr{Cint}), handle, out1, out2)
            return out1[], (out2[] != zero(Cint))
        end
    else
        @eval function $m(handle::$H)
            out1 = Ref{$T1}()
            out2 = Ref{$T2}()
            @call($f, Status, ($H, Ptr{$T1}, Ptr{$T2}), handle, out1, out2)
            return out1[], out2[]
        end
    end

end

#
# Methods for a handle and 1 other input argument.
#
# `m` is the Julia method, `H` is the handle type, `Tj` is the Julia type of
# the input argument, `f` is the C function to call, `Tc` is the C type of the
# input argument.
#
for (m, H, Tj, f, Tc) in (

    # int ncProcAddBiasImage(NcProc ctx, NcImage *bias);
    (:addBiasImage, Proc, Ptr{Image}, :ncProcAddBiasImage, Ptr{Image}),

    # int ncProcAddDataImage(NcProc ctx, NcImage *image);
    (:addDataImage, Proc, Ptr{Image}, :ncProcAddDataImage, Ptr{Image}),

    # int ncGrabCreateBias(NcGrab grab, int nbrImages);
    (:createBias, Grab, Integer, :ncGrabCreateBias, Cint),

    # int ncCamDeleteMRoi(NcCam cam, int index);
    (:deleteMRoi, Cam, Integer, :ncCamDeleteMRoi, Cint),

    # int ncGrabLoadParam(NcGrab grab, const char *saveName);
    (:loadParam, Grab, Name, :ncGrabLoadParam, Cstring),

    # int ncCamLoadParam(NcCam cam, const char *saveName);
    (:loadParam, Cam, Name, :ncCamLoadParam, Cstring),

    # int ncCamPrepareAcquisition(NcCam cam, int nbrImages);
    (:prepareAcquisition, Cam, Integer, :ncCamPrepareAcquisition, Cint),

    # int ncProcProcessDataImageInPlace(NcProc ctx, NcImage *image);
    (:processDataImageInPlace, Proc, Ptr{Image},
     :ncProcProcessDataImageInPlace, Ptr{Image}),

    # int ncCamReadUInt32(NcCam cam, uint32_t *image);
    (:read, Cam, Union{Ptr{UInt32},DenseMatrix{UInt32}},
     :ncCamReadUInt32, Ptr{UInt32}),

    # int ncCamReadFloat(NcCam cam, float *image);
    (:read, Cam, Union{Ptr{Cfloat},DenseMatrix{Cfloat}},
     :ncCamReadUInt32, Ptr{Cfloat}),

    # int ncProcReleaseImage(NcProc ctx, NcImage *image);
    (:releaseImage, Proc, Ptr{Image}, :ncProcReleaseImage, Ptr{Image}),

    # int ncGrabResetTimer(NcGrab grab, double timeOffset);
    (:resetTimer, Grab, Real, :ncGrabResetTimer, Cdouble),

    # int ncCamResetTimer(NcCam cam, double timeOffset);
    (:resetTimer, Cam, Real, :ncCamResetTimer, Cdouble),

    # int ncCamSetAnalogGain(NcCam cam, int analogGain);
    (:setAnalogGain, Cam, Integer, :ncCamSetAnalogGain, Cint),

    # int ncCamSetAnalogOffset(NcCam cam, int analogOffset);
    (:setAnalogOffset, Cam, Integer, :ncCamSetAnalogOffset, Cint),

    # int ncCamSetArmPolarity(NcCam cam, enum ExtPolarity armPolarity);
    (:setArmPolarity, Cam, ExtPolarity, :ncCamSetArmPolarity, ExtPolarity),

    # int ncGrabSetBaudrate(NcGrab grab, int baudrateSpeed);
    (:setBaudrate, Grab, Integer, :ncGrabSetBaudrate, Cint),

    # int ncProcSetBiasClampLevel(NcProc ctx, int biasClampLevel);
    (:setBiasClampLevel, Proc, Integer, :ncProcSetBiasClampLevel, Cint),

    # int ncCamSetCalibratedEmGain(NcCam cam, int calibratedEmGain);
    (:setCalibratedEmGain, Cam, Integer, :ncCamSetCalibratedEmGain, Cint),

    # int ncCamSetExposureTime(NcCam cam, double exposureTime);
    (:setExposureTime, Cam, Real, :ncCamSetExposureTime, Cdouble),

    # int ncCamSetExternalShutter(NcCam cam,
    #         enum ExtShutter externalShutterPresence);
    (:setExternalShutter, Cam, ExtShutter,
     :ncCamSetExternalShutter, ExtShutter),

    # int ncCamSetExternalShutterDelay(NcCam cam,
    #         double externalShutterDelay);
    (:setExternalShutterDelay, Cam, Real,
     :ncCamSetExternalShutterDelay, Cdouble),

    # int ncCamSetExternalShutterMode(NcCam cam,
    #         enum ShutterMode externalShutterMode);
    (:setExternalShutterMode, Cam, ShutterMode,
     :ncCamSetExternalShutterMode, ShutterMode),

    # int ncCamSetFirePolarity(NcCam cam, enum ExtPolarity firePolarity);
    (:setFirePolarity, Cam, ExtPolarity, :ncCamSetFirePolarity, ExtPolarity),

    # int ncGrabSetHeartbeat(NcGrab grab, int timeMs);
    (:setHeartbeat, Grab, Integer, :ncGrabSetHeartbeat, Cint),

    # int ncCamSetHeartbeat(NcCam cam, int timeMs);
    (:setHeartbeat, Cam, Integer, :ncCamSetHeartbeat, Cint),

    # int ncCamSetOutputMinimumPulseWidth(NcCam cam, double outputPulseWidth);
    (:setOutputMinimumPulseWidth, Cam, Real,
     :ncCamSetOutputMinimumPulseWidth, Cdouble),

    # int ncProcSetOverscanLines(NcProc ctx, int overscanLines);
    (:setOverscanLines, Proc, Integer, :ncProcSetOverscanLines, Cint),

    # int ncCamSetRawEmGain(NcCam cam, int rawEmGain);
    (:setRawEmGain, Cam, Integer, :ncCamSetRawEmGain, Cint),

    # int ncCamSetReadoutMode(NcCam cam, int value);
    (:setReadoutMode, Cam, Integer, :ncCamSetReadoutMode, Cint),

    # int ncGrabSaveImageSetCompressionType(NcGrab grab,
    #         enum ImageCompression compress);
    (:setCompressionType, Grab, ImageCompression,
     :ncGrabSaveImageSetCompressionType, ImageCompression),

    # int ncCamSaveImageSetCompressionType(NcCam cam,
    #         enum ImageCompression compress);
    (:setCompressionType, Cam, ImageCompression,
     :ncCamSaveImageSetCompressionType, ImageCompression),

    # int ncGrabSetSerialTimeout(NcGrab grab, int serialTimeout);
    (:setSerialTimeout, Grab, Integer, :ncGrabSetSerialTimeout, Cint),

    # int ncCamSetSerialCarTime(NcCam cam, double serialCarTime);
    (:setSerialCarTime, Cam, Real, :ncCamSetSerialCarTime, Cdouble),

    # int ncCamSetShutterMode(NcCam cam, enum ShutterMode shutterMode);
    (:setShutterMode, Cam, ShutterMode, :ncCamSetShutterMode, ShutterMode),

    # int ncCamSetShutterPolarity(NcCam cam, enum ExtPolarity shutterPolarity);
    (:setShutterPolarity,Cam,  ExtPolarity,
     :ncCamSetShutterPolarity, ExtPolarity),

    # int ncCamSetStatusPollRate(NcCam cam, int periodMs);
    (:setStatusPollRate, Cam, Integer, :ncCamSetStatusPollRate, Cint),

    # int ncCamSetTargetDetectorTemp(NcCam cam, double targetDetectorTemp);
    (:setTargetDetectorTemp, Cam, Real, :ncCamSetTargetDetectorTemp, Cdouble),

    # int ncGrabSetTimeout(NcGrab grab, int timeMs);
    (:setTimeout, Grab, Integer, :ncGrabSetTimeout, Cint),

    # int ncCamSetTimeout(NcCam cam, int timeMs);
    (:setTimeout, Cam, Integer, :ncCamSetTimeout, Cint),

    # int ncGrabSetTimestampMode(NcGrab grab,
    #         enum TimestampMode timestampMode);
    (:setTimestampMode, Grab, TimestampMode,
     :ncGrabSetTimestampMode, TimestampMode),

    # int ncCamSetTimestampMode(NcCam cam, enum TimestampMode timestampMode);
    (:setTimestampMode, Cam, TimestampMode,
     :ncCamSetTimestampMode, TimestampMode),

    # int ncProcSetProcType(NcProc ctx, int type);
    (:setProcType, Proc, Integer, :ncProcSetProcType, Cint),

    # int ncCamSetWaitingTime(NcCam cam, double waitingTime);
    (:setWaitingTime, Cam, Real, :ncCamSetWaitingTime, Cdouble),

    # int ncGrabStart(NcGrab grab, int nbrImages);
    (:start, Grab, Integer, :ncGrabStart, Cint),

     # int ncCamStart(NcCam cam, int nbrImages);
    (:start, Cam, Integer, :ncCamStart, Cint))

    @eval $m(handle::$H, inp::$Tj) =
        @call($f, Status, ($H, $Tc), handle, inp)

end

#
# Methods for a handle and 2 other input arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` and `Tj2` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1` and
# `Tc2` are the C types of the input arguments.
#
for (m, H, Tj1, Tj2, f, Tc1, Tc2) in (

    # int ncCamCreateBias(NcCam cam, int nbrImages,
    #         enum ShutterMode biasShuttermode);
    (:createBias, Cam, Integer, ShutterMode,
     :ncCamCreateBias, Cint, ShutterMode),

    # int ncGrabGetImageParams(NcGrab grab, void* image,
    #         ImageParams imageParams);
    (:getImageParams, Grab, Ptr{Void}, ImageParams{Grab},
     :ncGrabGetImageParams, Ptr{Void}, ImageParams{Grab}),

    # int ncCamGetImageParams(NcCam cam, void* image,
    #         ImageParams imageParams);
    (:getImageParams, Cam, Ptr{Void}, ImageParams{Cam},
     :ncCamGetImageParams, Ptr{Void}, ImageParams{Cam}),

    # int ncProcResize(NcProc ctx, int width, int height);
    (:resize, Proc, Integer, Integer,
     :ncProcResize, Cint, Cint),

    # int ncGrabSaveParam(NcGrab grab, const char *saveName,
    #         int overwriteFlag);
    (:saveParam, Grab, Name, Bool, :ncGrabSaveParam, Cstring, Cint),

    # int ncCamSaveParam(NcCam cam, const char* saveName, int overwriteFlag);
    (:saveParam, Cam, Name, Bool, :ncCamSaveParam, Cstring, Cint),

    # int ncGrabSendSerialBinaryComm(NcGrab grab, const char *command,
    #         int length);
    (:sendSerialCommand, Grab, Ptr{Char}, Integer,
     :ncGrabSendSerialBinaryComm, Ptr{Cchar}, Cint),

    # int ncCamSetBinningMode(NcCam cam, int binXValue, int binYValue);
    (:setBinningMode, Cam, Integer, Integer,
     :ncCamSetBinningMode, Cint, Cint),

    # int ncGrabSetSize(NcGrab grab, int width, int height);
    (:setSize, Grab, Integer, Integer,
     :ncGrabSetSize, Cint, Cint),

    # int ncGrabSetProcType(NcGrab grab, int type, int nbrImagesPc);
    (:setProcType, Grab, Integer, Integer,
     :ncGrabSetProcType, Cint, Cint),

    # int ncCamSetProcType(NcCam cam, int type, int nbrImagesPc);
    (:setProcType, Cam, Integer, Integer,
     :ncCamSetProcType, Cint, Cint),

    # int ncGrabSetTimestampInternal(NcGrab grab, struct tm *dateTime,
    #         int nbrUs);
    (:setTimestampInternal, Grab, Union{Ref{TmStruct},Ptr{TmStruct}}, Integer,
     :ncGrabSetTimestampInternal, Ptr{TmStruct}, Cint),

    # int ncCamSetTimestampInternal(NcCam cam, struct tm *dateTime,
    #         int nbrUs);
    (:setTimestampInternal, Cam, Union{Ref{TmStruct},Ptr{TmStruct}}, Integer,
     :ncCamSetTimestampInternal, Ptr{TmStruct}, Cint),

    # int ncCamSetTriggerMode(NcCam cam, enum TriggerMode triggerMode,
    #         int nbrImages);
    (:setTriggerMode, Cam, TriggerMode, Integer,
     :ncCamSetTriggerMode, TriggerMode, Cint))

    @eval $m(handle::$H, inp1::$Tj1, inp2::$Tj2) =
        @call($f, Status, ($H, $Tc1, $Tc2), handle, inp1, inp2)

end

#
# Methods for a handle and 3 other input arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1`, ..., `Tj3` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1`,
# ..., `Tc3` are the C types of the input arguments.
#
for (m, H, Tj1, Tj2, Tj3, f, Tc1, Tc2, Tc3) in (

    # int ncCamSetMRoiPosition(NcCam cam, int index, int offsetX, int offsetY);
    (:setMRoiPosition, Cam, Integer, Integer, Integer,
     :ncCamSetMRoiPosition, Cint, Cint, Cint),

    # int ncCamSetMRoiSize(NcCam cam, int index, int width, int height);
    (:setMRoiSize, Cam, Integer, Integer, Integer,
     :ncCamSetMRoiSize, Cint, Cint, Cint),
)
    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2, inp3::$Tj3)
        @call($f, Status, ($H, $Tc1, $Tc2, $Tc3), handle, inp1, inp2, inp3)
    end

end

#
# Methods for a handle and 4 other input arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1`, ..., `Tj4` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1`,
# ..., `Tc4` are the C types of the input arguments.
#
for (m, H, Tj1, Tj2, Tj3, Tj4, f, Tc1, Tc2, Tc3, Tc4) in (

    # int ncCamAddMRoi(NcCam cam, int offsetX, int offsetY,
    #         int width, int height);
    (:addMRoi, Cam, Integer, Integer, Integer, Integer,
     :ncCamAddMRoi, Cint, Cint, Cint, Cint),

    # int ncWriteFileHeader(NcImageSaved *currentFile,
    #         enum HeaderDataType dataType, const char *name,
    #         const void *value, const char *comment);
    (:writeFileHeader, ImageSaved, HeaderDataType, Name, Ptr{Void}, Name,
     :ncWriteFileHeader, HeaderDataType, Cstring, Ptr{Void}, Cstring),

    # int ncGrabSaveImage(NcGrab grab, const NcImage* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         int overwriteFlag);
    (:saveImage, Grab, Ptr{Image}, Name, ImageFormat, Bool,
     :ncGrabSaveImage, Ptr{Image}, Cstring, ImageFormat, Cint),
)
    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2,
                      inp3::$Tj3, inp4::$Tj4)
        @call($f, Status, ($H, $Tc1, $Tc2, $Tc3, $Tc4),
              handle, inp1, inp2, inp3, inp4)
    end

end

#
# Methods for a handle and 5 other input arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1`, ..., `Tj5` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1`,
# ..., `Tc5` are the C types of the input arguments.
#
for (m, H, Tj1, Tj2, Tj3, Tj4, Tj5, f, Tc1, Tc2, Tc3, Tc4, Tc5) in (

    # int ncGrabSaveImageEx(NcGrab grab, const void* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         enum ImageDataType dataFormat, int overwriteFlag);
    (:saveImage, Grab, Ptr{Void}, Name, ImageFormat, ImageDataType, Bool,
     :ncGrabSaveImageEx, Ptr{Void}, Cstring, ImageFormat, ImageDataType, Cint),

    # int ncCamSaveImage(NcCam cam, const NcImage* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         const char* addComments, int overwriteFlag);
    (:saveImage, Cam, Ptr{Image}, Name, ImageFormat, Name, Bool,
     :ncCamSaveImage, Ptr{Image}, Cstring, ImageFormat, Cstring, Cint),

    # int ncCamSaveUInt32Image(NcCam cam, const uint32_t *imageNc,
    #         const char *saveName, enum ImageFormat saveFormat,
    #         const char *addComments, int overwriteFlag);
    (:saveImage, Cam, ImageBuffer{UInt32}, Name, ImageFormat, Name, Bool,
     :ncCamSaveUInt32Image, Ptr{UInt32}, Cstring, ImageFormat, Cstring, Cint),

    # int ncCamSaveFloatImage(NcCam cam, const float *imageNc,
    #         const char *saveName, enum ImageFormat saveFormat,
    #         const char *addComments, int overwriteFlag);
    (:saveImage, Cam, ImageBuffer{Cfloat}, Name, ImageFormat, Name, Bool,
     :ncCamSaveFloatImage, Ptr{Cfloat}, Cstring, ImageFormat, Cstring, Cint),

    # int ncGrabStartSaveAcquisition(NcGrab grab, const char *saveName,
    #         enum ImageFormat saveFormat,
    #         int imagesPerCubes, int nbrOfCubes,
    #         int overwriteFlag);
    (:startSaveAcquisition, Grab, Name, ImageFormat, Integer, Integer, Bool,
     :ncGrabStartSaveAcquisition, Cstring, ImageFormat, Cint, Cint, Cint),
)

    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2,
                      inp3::$Tj3, inp4::$Tj4, inp5::$Tj5)
        @call($f, Status, ($H, $Tc1, $Tc2, $Tc3, $Tc4, $Tc5),
              handle, inp1, inp2, inp3, inp4, inp5)
    end

end

#
# Methods for a handle and 6 other input arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1`, ..., `Tj6` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1`,
# ..., `Tc6` are the C types of the input arguments.
#
for (m, H, Tj1, Tj2, Tj3, Tj4, Tj5, Tj6, f, Tc1, Tc2, Tc3, Tc4, Tc5, Tc6) in (

    # int ncCamSaveImageEx(NcCam cam, const void * imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         enum ImageDataType dataFormat,
    #         const char* addComments, int overwriteFlag);
    (:saveImage, Cam, Ptr{Void}, Name, ImageFormat, ImageDataType, Name, Bool,
     :ncCamSaveImageEx, Ptr{Void}, Cstring, ImageFormat, ImageDataType,
     Cstring, Cint),

    # int ncCamStartSaveAcquisition(NcCam cam, const char *saveName,
    #         enum ImageFormat saveFormat, int imagesPerCubes,
    #         const char *addComments, int nbrOfCubes, int overwriteFlag);
    (:startSaveAcquisition, Cam, Name, ImageFormat, Integer, Name, Integer,
     Bool,
     :ncCamStartSaveAcquisition, Cstring, ImageFormat, Cint, Cstring, Cint,
     Cint),
)
    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2,
                      inp3::$Tj3, inp4::$Tj4, inp5::$Tj5, inp6::$Tj6)
        @call($f, Status, ($H, $Tc1, $Tc2, $Tc3, $Tc4, $Tc5, $Tc6),
              handle, inp1, inp2, inp3, inp4, inp5, inp6)
    end

end

#
# Methods for a handle, 1 input argument and 1 output argument.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` is the Julia types of
# the input argument, `f` is the C function to call, `Tc1` is the C type of the
# input argument and `Tc2` is the C type of the output argument.
#
for (m, H, Tj1, f, Tc1, Tc2) in (

    # int ncCamGetAmpliTypeAvail(NcCam cam, enum Ampli ampli, int *number);
    (:getAmpliTypeAvail, Cam, Ampli,
     :ncCamGetAmpliTypeAvail, Ampli, Cint),

    # int ncCamGetAnalogGain(NcCam cam, int cameraRequest, int* analogGain);
    (:getAnalogGain, Cam, Bool,
     :ncCamGetAnalogGain, Cint, Cint),

    # int ncCamGetAnalogOffset(NcCam cam, int cameraRequest,
    #         int* analogOffset);
    (:getAnalogOffset, Cam, Bool,
     :ncCamGetAnalogOffset, Cint, Cint),

    # int ncCamGetArmPolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* armPolarity);
    (:getArmPolarity, Cam, Bool,
     :ncCamGetArmPolarity, Cint, ExtPolarity),

    # int ncCamGetCalibratedEmGain(NcCam cam, int cameraRequest,
    #         int *calibratedEmGain);
    (:getCalibratedEmGain, Cam, Bool,
     :ncCamGetCalibratedEmGain, Cint, Cint),

    # int ncCamGetComponentTemp(NcCam cam, enum NcTemperatureType temp,
    #         double* value);
    (:getComponentTemp, Cam, TemperatureType,
     :ncCamGetComponentTemp, TemperatureType, Cdouble),

    # int ncCamGetExposureTime(NcCam cam, int cameraRequest,
    #         double* exposureTime);
    (:getExposureTime, Cam, Bool,
     :ncCamGetExposureTime, Cint, Cdouble),

    # int ncCamGetExternalShutter(NcCam cam, int cameraRequest,
    #         enum ExtShutter* externalShutterPresence);
    (:getExternalShutter, Cam, Bool,
     :ncCamGetExternalShutter, Cint, ExtShutter),

    # int ncCamGetExternalShutterDelay(NcCam cam, int cameraRequest,
    #         double* externalShutterDelay);
    (:getExternalShutterDelay, Cam, Bool,
     :ncCamGetExternalShutterDelay, Cint, Cdouble),

    # int ncCamGetExternalShutterMode(NcCam cam, int cameraRequest,
    #         enum ShutterMode* externalShutterMode);
    (:getExternalShutterMode, Cam, Bool,
     :ncCamGetExternalShutterMode, Cint, ShutterMode),

    # int ncCamGetFirePolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* firePolarity);
    (:getFirePolarity, Cam, Bool,
     :ncCamGetFirePolarity, Cint, ExtPolarity),

    # int ncControllerListGetFreePortChannel(const NcCtrlList ctrlList,
    #         int index, int * channel);
    (:getFreePortChannel, CtrlList, Integer,
     :ncControllerListGetFreePortChannel, Cint, Cint),

    # int ncControllerListGetFreePortReason(const NcCtrlList ctrlList,
    #         int index, enum NcPortUnusedReason* reason);
    (:getFreePortReason, CtrlList, Integer,
     :ncControllerListGetFreePortReason, Cint, PortUnusedReason),

    # int ncControllerListGetFreePortUnit(const NcCtrlList ctrlList,
    #         int index, int * unit);
    (:getFreePortUnit, CtrlList, Integer,
     :ncControllerListGetFreePortUnit, Cint, Cint),

    # int ncGrabGetHostSystemTimestamp(NcGrab grab, NcImage* imageAcqu,
    #         double *hostSystemTimestamp);
    (:getHostSystemTimestamp, Grab, Ptr{Image},
     :ncGrabGetHostSystemTimestamp, Ptr{Image}, Cdouble),

    # int ncCamGetHostSystemTimestamp(NcCam cam, NcImage* imageAcqu,
    #         double *hostSystemTimestamp);
    (:getHostSystemTimestamp, Cam, Ptr{Image},
     :ncCamGetHostSystemTimestamp, Ptr{Image}, Cdouble),

    # int ncCamGetOutputMinimumPulseWidth(NcCam cam, int cameraRequest,
    #         double *outputPulseWidth);
    (:getOutputMinimumPulseWidth, Cam, Bool,
     :ncCamGetOutputMinimumPulseWidth, Cint, Cdouble),

    # int ncControllerListGetPortChannel(const NcCtrlList ctrlList,
    #         int index, int * channel);
    (:getPortChannel, CtrlList, :Integer,
     :ncControllerListGetPortChannel, Cint, Cint),

    # int ncControllerListGetPortUnit(const NcCtrlList ctrlList,
    #         int index, int * unit);
    (:getPortUnit, CtrlList, Integer,
     :ncControllerListGetPortUnit, Cint, Cint),

    # int ncCamGetRawEmGain(NcCam cam, int cameraRequest, int* rawEmGain);
    (:getRawEmGain, Cam, Bool,
     :ncCamGetRawEmGain, Cint, Cint),

    # int ncCamGetSerialCarTime(NcCam cam, int cameraRequest,
    #         double* serialCarTime);
    (:getSerialCarTime, Cam, Bool,
     :ncCamGetSerialCarTime, Cint, Cdouble),

    # int ncCamGetShutterMode(NcCam cam, int cameraRequest,
    #         enum ShutterMode* shutterMode);
    (:getShutterMode, Cam, Bool,
     :ncCamGetShutterMode, Cint, ShutterMode),

    # int ncCamGetShutterPolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* shutterPolarity);
    (:getShutterPolarity, Cam, Bool,
     :ncCamGetShutterPolarity, Cint, ExtPolarity),

    # int ncCamGetTargetDetectorTemp(NcCam cam, int cameraRequest,
    #         double* targetDetectorTemp);
    (:getTargetDetectorTemp, Cam, Bool,
     :ncCamGetTargetDetectorTemp, Cint, Cdouble),

    # int ncCamGetWaitingTime(NcCam cam, int cameraRequest,
    #         double* waitingTime);
    (:getWaitingTime, Cam, Bool,
     :ncCamGetWaitingTime, Cint, Cdouble),

    # int ncCamReadUInt32Chronological(NcCam cam,
    #         uint32_t* imageAcqu, int* nbrImagesSkipped);
    (:readChronological, Cam, ImageBuffer{UInt32},
     :ncCamReadUInt32Chronological, Ptr{UInt32}, Cint),

    # int ncCamReadFloatChronological(NcCam cam,
    #         float* imageAcqu, int* nbrImagesSkipped);
    (:readChronological, Cam, ImageBuffer{Cfloat},
     :ncCamReadFloatChronological, Ptr{Cfloat}, Cint),

    # int ncCamReadUInt32ChronologicalNonBlocking(NcCam cam,
    #         uint32_t* imageAcqu, int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, Cam, ImageBuffer{UInt32},
     :ncCamReadUInt32ChronologicalNonBlocking, Ptr{UInt32}, Cint),

    # int ncCamReadFloatChronologicalNonBlocking(NcCam cam,
    #         float* imageAcqu, int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, Cam, ImageBuffer{Cfloat},
     :ncCamReadFloatChronologicalNonBlocking, Ptr{Cfloat}, Cint),

    # int ncGrabWaitSerialCmd(NcGrab grab, int length, int* numByte);
    (:waitSerialCommand, Grab, Integer,
     :ncGrabWaitSerialCmd, Cint, Cint),
)
    @eval function $m(handle::$H, inp::$Tj1)
        out = Ref{$Tc2}()
        @call($f, Status, ($H, $Tc1, Ptr{$Tc2}), handle, inp, out)
        return out[]
    end

end

#
# Methods for a handle, 1 input argument and 2 output arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` is the Julia types of
# the input argument, `f` is the C function to call, `Tc1` is the C type of the
# input argument and `Tc2` and `Tc3` are the C type of the output arguments.
#
# It the type of the last output argument is `Bool`, then a `Cint` is retrieved
# and a boolean value is returned.
#
for (m, H, Tj1, f, Tc1, Tc2, Tc3) in (

    # int ncControllerListGetDetectorSize(const NcCtrlList ctrlList,
    #         int index, int* detectorSizeX, int* detectorSizeY);
    (:getDetectorSize, CtrlList, Integer,
     :ncControllerListGetDetectorSize, Cint, Cint, Cint),

    # int ncControllerListGetFullSizeSize(const NcCtrlList ctrlList,
    #         int index, int* detectorSizeX, int* detectorSizeY);
    (:getFullSize, CtrlList, Integer,
     :ncControllerListGetFullSizeSize, Cint, Cint, Cint),

    # int ncCamGetMRoiPosition(NcCam cam, int index,
    #         int* offsetX, int* offsetY);
    (:getMRoiPosition, Cam, Integer,
     :ncCamGetMRoiPosition, Cint, Cint, Cint),

    # int ncCamGetMRoiSize(NcCam cam, int index, int* width, int* height);
    (:getMRoiSize, Cam, Integer,
     :ncCamGetMRoiSize, Cint, Cint, Cint),

    # int ncGrabGetTimestampMode(NcGrab grab, int ctrlRequest,
    #         enum TimestampMode *timestampMode, int *gpsSignalValid);
    (:getTimestampMode, Grab, Bool,
     :ncGrabGetTimestampMode, Cint, TimestampMode, Bool),

    # int ncCamGetTimestampMode(NcCam cam, int cameraRequest,
    #         enum TimestampMode *timestampMode, int *gpsSignalValid);
    (:getTimestampMode, Cam, Bool,
     :ncCamGetTimestampMode, Cint, TimestampMode, Bool),

    # int ncCamGetTriggerMode(NcCam cam, int cameraRequest,
    #         enum TriggerMode* triggerMode, int* nbrImagesPerTrig);
    (:getTriggerMode, Cam, Bool,
     :ncCamGetTriggerMode, Cint, TriggerMode, Cint),
)
    if Tc3 == Bool
        @eval function $m(handle::$H, inp::$Tj1)
            out1 = Ref{$Tc2}()
            out2 = Ref{Cint}()
            @call($f, Status,
                  ($H, $Tc1, Ptr{$Tc2}, Ptr{Cint}),
                  handle, inp, out1, out2)
            return (out1[], (out2[] != zero(Cint)))
        end
    else
        @eval function $m(handle::$H, inp::$Tj1)
            out1 = Ref{$Tc2}()
            out2 = Ref{$Tc3}()
            @call($f, Status,
                  ($H, $Tc1, Ptr{$Tc2}, Ptr{$Tc3}),
                  handle, inp, out1, out2)
            return (out1[], out2[])
        end
    end
end

#
# Methods for a handle, 1 input argument and 3 output arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` is the Julia types of
# the input argument, `f` is the C function to call, `Tc1` is the C type of the
# input argument and `Tc2`, ... `Tc4` are the C type of the output arguments.
#
for (m, H, Tj1, f, Tc1, Tc2, Tc3, Tc4) in (

    # int ncGrabGetCtrlTimestamp(NcGrab grab, NcImage* imageAcqu,
    #         struct tm *ctrTimestamp, double *ctrlSecondFraction,
    #         int *status);
    (:getCtrlTimestamp, Grab, Ptr{Image},
     :ncGrabGetCtrlTimestamp, Ptr{Image}, TmStruct, Cdouble, Cint),

    # int ncCamGetCtrlTimestamp(NcCam cam, NcImage* imageAcqu,
    #         struct tm *ctrTimestamp, double *ctrlSecondFraction,
    #         int *status);
    (:getCtrlTimestamp, Cam, Ptr{Image},
     :ncCamGetCtrlTimestamp, Ptr{Image}, TmStruct, Cdouble, Cint),
)
    @eval function $m(handle::$H, inp::$Tj1)
        out1 = Ref{$Tc2}()
        out2 = Ref{$Tc3}()
        out3 = Ref{$Tc4}()
        @call($f, Status,
              ($H, $Tc1, Ptr{$Tc2}, Ptr{$Tc3}, Ptr{$Tc4}),
              handle, inp, out1, out2, out3)
        return (out1[], out2[], out3[])
    end

end

#
# Methods for a handle, 1 input argument and 4 output arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` is the Julia types of
# the input argument, `f` is the C function to call, `Tc1` is the C type of the
# input argument and `Tc2`, ... `Tc5` are the C type of the output arguments.
#
for (m, H, Tj1, f, Tc1, Tc2, Tc3, Tc4, Tc5) in (

    # int ncCamGetMRoiInputRegion(ImageParams params, int index,
    #         int* offsetX, int* offsetY, int* width, int* height);
    (:getMRoiInputRegion, ImageParams{Cam}, Integer,
     :ncCamGetMRoiInputRegion, Cint, Cint, Cint, Cint, Cint),

    # int ncCamGetMRoiOutputRegion(ImageParams params, int index,
    #         int * offsetX, int* offsetY, int* width, int* height);
    (:getMRoiOutputRegion, ImageParams{Cam}, Integer,
     :ncCamGetMRoiOutputRegion, Cint, Cint, Cint, Cint, Cint),
)
    @eval function $m(handle::$H, inp::$Tj1)
        out1 = Ref{$Tc2}()
        out2 = Ref{$Tc3}()
        out3 = Ref{$Tc4}()
        out4 = Ref{$Tc5}()
        @call($f, Status,
              ($H, $Tc1, Ptr{$Tc2}, Ptr{$Tc3}, Ptr{$Tc4}, Ptr{$Tc5}),
              handle, inp, out1, out2, out3, out4)
        return (out1[], out2[], out3[], out4[])
    end

end

#
# Methods for a handle, 2 input arguments and 1 output argument.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` and `Tj2` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1` and
# `Tc2` are the C type of the input arguments and `Tc3` is the C type of the
# output argument.
#
for (m, H, Tj1, Tj2, f, Tc1, Tc2, Tc3) in (

    # int ncGrabRecSerial(NcGrab grab, char *recBuffer, int length,
    #         int* numByte);
    (:readSerial, Grab, Union{DenseVector{Cchar},Ptr{Cchar}}, Integer,
     :ncGrabRecSerial, Ptr{Cchar}, Cint, Cint),
)
    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2)
        out = Ref{$Tc3}()
        @call($f, Status, ($H, $Tc1, $Tc2, Ptr{$Tc3}), handle, inp1, inp2, out)
        return out[]
    end

end

#
# Methods for a handle, 2 input arguments and 3 output arguments.
#
# `m` is the Julia method, `H` is the handle type, `Tj1` and `Tj2` are the
# Julia types of the input arguments, `f` is the C function to call, `Tc1` and
# `Tc2` are the C type of the input arguments, `Tc3` to `Tc5` are the C type
# of the output arguments.
#
for (m, H, Tj1, Tj2, f, Tc1, Tc2, Tc3, Tc4, Tc5) in (

    # int ncCamGetFreqAvail(NcCam cam, enum Ampli ampli, int ampliNo,
    #         int *vertFreq, int *horizFreq, int* readoutModeNo);
    (:getFreqAvail, Cam, Ampli, Integer,
     :ncCamGetFreqAvail, Ampli, Cint, Cint, Cint, Cint),
)
    @eval function $m(handle::$H, inp1::$Tj1, inp2::$Tj2)
        out1 = Ref{$Tc3}()
        out2 = Ref{$Tc4}()
        out3 = Ref{$Tc5}()
        @call($f, Status, ($H, $Tc1, $Tc2, Ptr{$Tc3}, Ptr{$Tc4}, Ptr{$Tc5}),
              handle, inp1, inp2, out1, out2, out3)
        return (out1[], out2[], out3[])
    end

end

#------------------------------------------------------------------------------
# PROCESSING FUNCTIONS

function open(::Type{Proc}, width::Integer, height::Integer)
    procCtx = Ref{Proc}()
    # int ncProcOpen(int width, int height, NcProc* procCtx);
    @call(:ncProcOpen, Status, (Cint, Cint, Ptr{Proc}), width, height, procCtx)
    return procCtx[]
end

function processDataImageInPlaceForceType(ctx::Proc, image::Ptr{Image},
                                          procType::Integer)
    # int ncProcProcessDataImageInPlaceForceType(NcProc ctx, NcImage *image, int procType);
    @call(:ncProcProcessDataImageInPlaceForceType, Status,
          (Proc, Ptr{Image}, Cint), ctx, image, procType)
end

save(ctx::Proc, name::Name, overwrite::Bool) =
    # int ncProcSave(NcProc ctx, const char *saveName, int overwriteFlag);
    @call(:ncProcSave, Status, (Proc, Ptr{Cchar}, Cint),
          ctx, name, overwrite)

load(ctx::Proc, name::Name) =
    # int ncProcLoad(NcProc procCtx, const char *saveName);
    @call(:ncProcLoad, Status, (Proc, Cstring), ctx, name)

#------------------------------------------------------------------------------
# STATISTICAL FUNCTIONS

function open(::Type{StatsCtx}, imageWidth::Integer, imageHeight::Integer)
    statsCtx = Ref{StatsCtx}()
    # int ncStatsOpen(int imageWidth, int imageHeight, NcStatsCtx** statsCtx);
    @call(:ncStatsOpen, Status, (Cint, Cint, Ptr{StatsCtx}),
          imageWidth, imageHeight, statsCtx)
    return statsCtx[]
end


resize(statsCtx::StatsCtx, imageWidth::Integer, imageHeight::Integer) =
    # int ncStatsResize(NcStatsCtx *statsCtx, int imageWidth, int imageHeight);
    @call(:ncStatsResize, Status, (StatsCtx, Cint, Cint),
          statsCtx, imageWidth, imageHeight)

"""
```julia
getHistoCrossSection(statsCtx, regionIndex, image, xCoord, yCoord)
 -> stats, histoPtr, crossSectionHorizontalPtr, crossSectionVerticalPtr
```

```julia
histo = fetcharray(histoPtr, 65536)
crossSectionHorizontal = fetcharray(crossSectionHorizontalPtr, regionWidth)
crossSectionVertical = fetcharray(crossSectionVerticalPtr, regionHeight)
```

""" getHistoCrossSection

for i in 1:3

    T = (Cam, Grab, StatsCtx)[i]

    # int ncCamStatsAddRegion(NcCam cam, int regionWidth,
    #         int regionHeight, int *regionIndex);
    # int ncGrabStatsAddRegion(NcGrab grab, int regionWidth,
    #         int regionHeight, int *regionIndex);
    # int ncStatsAddRegion(NcStatsCtx *statsCtx, int regionWidth,
    #         int regionHeight, int *regionIndex);

    f = (:ncCamStatsAddRegion,
         :ncGrabStatsAddRegion,
         :ncStatsAddRegion)[i]

    @eval function addRegion(handle::$T, regionWidth::Integer,
        regionHeight::Integer)
        regionIndex = Ref{Cint}()
        @call($f, Status, ($T, Cint, Cint, Ptr{Cint}),
              handle, regionWidth, regionHeight, regionIndex)
        return regionIndex[]
    end

    # int ncCamStatsRemoveRegion(NcCam cam, int regionIndex);
    # int ncGrabStatsRemoveRegion(NcGrab grab, int regionIndex);
    # int ncStatsRemoveRegion(NcStatsCtx *statsCtx, int regionIndex);

    f = (:ncCamStatsRemoveRegion,
         :ncGrabStatsRemoveRegion,
         :ncStatsRemoveRegion)[i]

    @eval removeRegion(handle::$T, regionIndex::Integer) =
        @call($f, Status, ($T, Cint), handle, regionIndex)

    # int ncCamStatsResizeRegion(NcCam cam, int regionIndex,
    #         int regionWidth, int regionHeight);
    # int ncGrabStatsResizeRegion(NcGrab grab, int regionIndex,
    #         int regionWidth, int regionHeight);
    # int ncStatsResizeRegion(NcStatsCtx *statsCtx, int regionIndex,
    #         int regionWidth, int regionHeight);

    f = (:ncCamStatsResizeRegion,
         :ncGrabStatsResizeRegion,
         :ncStatsResizeRegion)[i]

    @eval function resizeRegion(handle::$T, regionIndex::Integer,
        regionWidth::Integer, regionHeight::Integer)
        @call($f, Status, ($T, Cint, Cint, Cint),
              handle, regionIndex, regionWidth, regionHeight)
    end

    # int ncCamStatsGetCrossSection(NcCam cam, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double statsCtxRegion[5], double **histo,
    #         double **crossSectionHorizontal,
    #         double **crossSectionVertical);
    # int ncGrabStatsGetCrossSection(NcGrab grab, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double statsCtxRegion[5], double **histo,
    #         double **crossSectionHorizontal,
    #         double **crossSectionVertical);
    # int ncStatsGetHistoCrossSection(NcStatsCtx *statsCtx, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double statsCtxRegion[5], double **histo,
    #         double **crossSectionHorizontal,
    #         double **crossSectionVertical);

    f = (:ncCamStatsGetCrossSection,
         :ncGrabStatsGetCrossSection,
         :ncStatsGetHistoCrossSection)[i]

    @eval function getHistoCrossSection(handle::$T, regionIndex::Integer,
        image::Ptr{Image}, xCoord::Integer,
        yCoord::Integer)
        stats = Array{Cdouble}(5)
        histo = Ref{Ptr{Cdouble}}()
        crossSectionHorizontal = Ref{Ptr{Cdouble}}()
        crossSectionVertical = Ref{Ptr{Cdouble}}()
        @call($f, Status,
              ($T, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble},
               Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
              handle, regionIndex, image, xCoord, yCoord, stats, histo,
              crossSectionHorizontal, crossSectionVertical)
        return (stats, histo[], crossSectionHorizontal[],
        crossSectionVertical[])
    end

    # int ncCamStatsGetGaussFit(NcCam cam, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double *maxAmplitude, double gaussSumHorizontal[3],
    #         double gaussSumVertical[3], int useActualCrossSection);
    # int ncGrabStatsGetGaussFit(NcGrab grab, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double *maxAmplitude, double gaussSumHorizontal[3],
    #         double gaussSumVertical[3], int useActualCrossSection);
    # int ncStatsGetGaussFit(NcStatsCtx *statsCtx, int regionIndex,
    #         const NcImage *image, int xCoord, int yCoord,
    #         double *maxAmplitude, double gaussSumHorizontal[3],
    #         double gaussSumVertical[3], int useActualCrossSection);

    f = (:ncCamStatsGetGaussFit,
         :ncGrabStatsGetGaussFit,
         :ncStatsGetGaussFit)[i]

    @eval function getGaussFit(handle::$T, regionIndex::Integer,
        image::Ptr{Image}, xCoord::Integer,
        yCoord::Integer, useActualCrossSection::Bool)
        maxAmplitude = Ref{Cdouble}()
        gaussSumHorizontal = Array{Cdouble}(3)
        gaussSumVertical = Array{Cdouble}(3)
        @call($f, Status, ($T, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble},
                           Ptr{Cdouble}, Ptr{Cdouble}, Cint),
              handle, regionIndex, image, xCoord, yCoord, maxAmplitude,
              gaussSumHorizontal, gaussSumVertical, useActualCrossSection)
        return maxAmplitude[], gaussSumHorizontal, gaussSumVertical
    end

end


#------------------------------------------------------------------------------
# PARAMETERS

getParam(::Type{Bool}, handle::Union{Cam,Grab}, name::Name) =
    (getParamInt(handle, name) != 0)

getParam(::Type{T}, handle::Union{Cam,Grab}, name::Name) where {T<:Integer} =
    convert(T, getParamInt(handle, name))

getParam(::Type{T}, handle::Union{Cam,Grab}, name::Name) where {T<:AbstractFloat} =
    convert(T, getParamDbl(handle, name))

function getParam(::Type{String}, handle::Union{Cam,Grab}, name::Name)
    siz = getParamStrSize(handle, name)
    buf = Array{UInt8}(siz + 1) # FIXME: check this!
    getParamStr(handle, name, buf)
    return stringify!(buf)
end

getParam(::Type{Function}, handle::Union{Cam,Grab}, name::Name) =
    getParamCallback(handle, name)


for (m, H, f) in (

    # int ncGrabParamGetCountInt(NcGrab grab, int* count);
    (:getParamCountInt, Grab, :ncGrabParamGetCountInt),

    # int ncCamParamGetCountInt(NcCam cam, int* count);
    (:getParamCountInt, Cam, :ncCamParamGetCountInt),

    # int ncGrabParamGetCountDbl(NcGrab grab, int* count);
    (:getParamCountDbl, Grab, :ncGrabParamGetCountDbl),

    # int ncCamParamGetCountDbl(NcCam cam, int* count);
    (:getParamCountDbl, Cam, :ncCamParamGetCountDbl),

    # int ncGrabParamGetCountStr(NcGrab grab, int* count);
    (:getParamCountStr, Grab, :ncGrabParamGetCountStr),

    # int ncCamParamGetCountStr(NcCam cam, int* count);
    (:getParamCountStr, Cam, :ncCamParamGetCountStr),

    # int ncGrabParamGetCountVoidPtr(NcGrab grab, int* count);
    (:getParamCountVoidPtr, Grab, :ncGrabParamGetCountVoidPtr),

    # int ncCamParamGetCountVoidPtr(NcCam cam, int* count);
    (:getParamCountVoidPtr, Cam, :ncCamParamGetCountVoidPtr),

    # int ncGrabParamGetCountCallback(NcGrab grab, int* count);
    (:getParamCountCallback, Grab, :ncGrabParamGetCountCallback),

    # int ncCamParamGetCountCallback(NcCam cam, int* count);
    (:getParamCountCallback, Cam, :ncCamParamGetCountCallback))

    @eval function $m(handle::$H)
        value = Ref{Cint}()
        @call($f, Status, ($H, Ptr{Cint}), handle, value)
        return value[]
    end

end

for (m, H, f) in (

    # int ncGrabParamSupportedInt(NcGrab grab, const char* paramName,
    #         int* supported);
    (:supportedParamInt, Grab, :ncGrabParamSupportedInt),

    # int ncCamParamSupportedInt(NcCam cam, const char* paramName,
    #         int* supported);
    (:supportedParamInt, Cam, :ncCamParamSupportedInt),

    # int ncGrabParamSupportedDbl(NcGrab grab, const char* paramName, int* supported);
    (:supportedParamDbl, Grab, :ncGrabParamSupportedDbl),

    # int ncCamParamSupportedDbl(NcCam cam, const char* paramName, int* supported);
    (:supportedParamDbl, Cam, :ncCamParamSupportedDbl),

    # int ncGrabParamSupportedStr(NcGrab grab, const char* paramName, int* supported);
    (:supportedParamStr, Grab, :ncGrabParamSupportedStr),

    # int ncCamParamSupportedStr(NcCam cam, const char* paramName, int* supported);
    (:supportedParamStr, Cam, :ncCamParamSupportedStr),

    # int ncGrabParamSupportedVoidPtr(NcGrab grab, const char* paramName, int* supported);
    (:supportedParamVoidPtr, Grab, :ncGrabParamSupportedVoidPtr),

    # int ncCamParamSupportedVoidPtr(NcCam cam, const char* paramName, int* supported);
    (:supportedParamVoidPtr, Cam, :ncCamParamSupportedVoidPtr),

    # int ncGrabParamSupportedCallback(NcGrab grab, const char* paramName, int* supported);
    (:supportedParamCallback, Grab, :ncGrabParamSupportedCallback),

    # int ncCamParamSupportedCallback(NcCam cam, const char* paramName, int* supported);
    (:supportedParamCallback, Cam, :ncCamParamSupportedCallback))

    @eval function $m(handle::$H, name::Name)
        flag = Ref{Cint}()
        @call($f, Status, ($H, Cstring, Ptr{Cint}), handle, name, flag)
        return (flag[] != 0)
    end

end

for (m, H, f) in (

    # int ncGrabParamGetNameInt(NcGrab grab, int index, const char** name);
    (:getParamNameInt, Grab, :ncGrabParamGetNameInt),

    # int ncCamParamGetNameInt(NcCam cam, int index, const char** name);
    (:getParamNameInt, Cam, :ncCamParamGetNameInt),

    # int ncGrabParamGetNameDbl(NcGrab grab, int index, const char** name);
    (:getParamNameDbl, Grab, :ncGrabParamGetNameDbl),

    # int ncCamParamGetNameDbl(NcCam cam, int index, const char** name);
    (:getParamNameDbl, Cam, :ncCamParamGetNameDbl),

    # int ncGrabParamGetNameStr(NcGrab grab, int index, const char** name);
    (:getParamNameStr, Grab, :ncGrabParamGetNameStr),

    # int ncCamParamGetNameStr(NcCam cam, int index, const char** name);
    (:getParamNameStr, Cam, :ncCamParamGetNameStr),

    # int ncGrabParamGetNameVoidPtr(NcGrab grab, int index, const char** name);
    (:getParamNameVoidPtr, Grab, :ncGrabParamGetNameVoidPtr),

    # int ncCamParamGetNameVoidPtr(NcCam cam, int index, const char** name);
    (:getParamNameVoidPtr, Cam, :ncCamParamGetNameVoidPtr),

    # int ncGrabParamGetNameCallback(NcGrab grab, int index, const char** name);
    (:getParamNameCallback, Grab, :ncGrabParamGetNameCallback),

    # int ncCamParamGetNameCallback(NcCam cam, int index, const char** name);
    (:getParamNameCallback, Cam, :ncCamParamGetNameCallback))

    @eval function $m(handle::$H, index::Integer)
        ptr = Ref{Ptr{Cchar}}()
        @call($f, Status, ($H, Cint, Ptr{Ptr{Cchar}}), handle, index, ptr)
        return unsafe_string(ptr[])
    end

end

for (m, H, Tj, f, Tc) in (

    # int ncGrabParamSetInt(NcGrab grab, const char* paramName, int value);
    (:setParamInt, Grab, Integer, :ncGrabParamSetInt, Cint),

    # int ncCamParamSetInt(NcCam cam, const char* paramName, int value);
    (:setParamInt, Cam, Integer, :ncCamParamSetInt, Cint),

    # int ncGrabParamSetDbl(NcGrab grab, const char* paramName, double value);
    (:setParamDbl, Grab, Real, :ncGrabParamSetDbl, Cdouble),

    # int ncCamParamSetDbl(NcCam cam, const char* paramName, double value);
    (:setParamDbl, Cam, Real, :ncCamParamSetDbl, Cdouble),

    # int ncGrabParamSetStr(NcGrab grab, const char* paramName,
    #         const char* value);
    (:setParamStr, Grab, Name, :ncGrabParamSetStr, Cstring),

    # int ncCamParamSetStr(NcCam cam, const char* paramName, const char* value);
    (:setParamStr, Cam, Name, :ncCamParamSetStr, Cstring),

    # int ncGrabParamSetVoidPtr(NcGrab grab, const char* paramName,
    #         void* value);
    (:setParamVoidPtr, Grab, Ptr, :ncGrabParamSetVoidPtr, Ptr{Void}),

    # int ncCamParamSetVoidPtr(NcCam cam, const char* paramName, void* value);
    (:setParamVoidPtr, Cam, Ptr, :ncCamParamSetVoidPtr, Ptr{Void}))

    @eval $m(handle::$H, name::Name, value::$Tj) =
        @call($f, Status, ($H, Cstring, $Tc), handle, name, value)

end

for (m, H, f) in (

    # int ncGrabParamSetCallback(NcGrab grab, const char* paramName,
    #         void(*callback)(void*), void* data);
    (:setParamCallback, Grab, :ncGrabParamSetCallback),

    # int ncCamParamSetCallback(NcCam cam, const char* paramName,
    #         void(*callback)(void*), void *data);
    (:setParamCallback, Cam, :ncCamParamSetCallback))

    @eval $m(handle::$H, name::Name, fct::Ptr{Void}, data::Ptr{Void}) =
        @call($f, Status, ($H, Cstring, Ptr{Void}, Ptr{Void}),
              handle, name, fct, data)
end


for (m, H, f) in (

    # int ncGrabParamUnsetInt(NcGrab grab, const char * paramName);
    (:unsetParamInt, Grab, :ncGrabParamUnsetInt),

    # int ncCamParamUnsetInt(NcCam cam, const char * paramName);
    (:unsetParamInt, Cam, :ncCamParamUnsetInt),

    # int ncGrabParamUnsetDbl(NcGrab grab, const char * paramName);
    (:unsetParamDbl, Grab, :ncGrabParamUnsetDbl),

    # int ncCamParamUnsetDbl(NcCam cam, const char * paramName);
    (:unsetParamDbl, Cam, :ncCamParamUnsetDbl),

    # int ncGrabParamUnsetStr(NcGrab grab, const char * paramName);
    (:unsetParamStr, Grab, :ncGrabParamUnsetStr),

    # int ncCamParamUnsetStr(NcCam cam, const char * paramName);
    (:unsetParamStr, Cam, :ncCamParamUnsetStr),

    # int ncGrabParamUnsetVoidPtr(NcGrab grab, const char * paramName);
    (:unsetParamVoidPtr, Grab, :ncGrabParamUnsetVoidPtr),

    # int ncCamParamUnsetVoidPtr(NcCam cam, const char * paramName);
    (:unsetParamVoidPtr, Cam, :ncCamParamUnsetVoidPtr),

    # int ncGrabParamUnsetCallback(NcGrab grab, const char * paramName);
    (:unsetParamCallback, Grab, :ncGrabParamUnsetCallback),

    # int ncCamParamUnsetCallback(NcCam cam, const char * paramName);
    (:unsetParamCallback, Cam, :ncCamParamUnsetCallback))

    @eval $m(handle::$H, name::Name) =
        @call($f, Status, ($H, Cstring), handle, name)

end


for (m, H, f, T) in (

    # int ncGrabParamGetInt(NcGrab grab, const char* paramName, int* value);
    (:getParamInt, Grab, :ncGrabParamGetInt, Cint),

    # int ncCamParamGetInt(NcCam cam, const char* paramName, int* value);
    (:getParamInt, Cam, :ncCamParamGetInt, Cint),

    # int ncGrabParamGetDbl(NcGrab grab, const char* paramName, double* value);
    (:getParamDbl, Grab, :ncGrabParamGetDbl, Cdouble),

    # int ncCamParamGetDbl(NcCam cam, const char* paramName, double* value);
    (:getParamDbl, Cam, :ncCamParamGetDbl, Cdouble),

    # int ncGrabParamGetStrSize(NcGrab grab, const char* paramName,
    #        int* valueSize);
    (:getParamStrSize, Grab, :ncGrabParamGetStrSize, Cint),

    # int ncCamParamGetStrSize(NcCam cam, const char* paramName,
    #        int* valueSize);
    (:getParamStrSize, Cam, :ncCamParamGetStrSize, Cint),

    # int ncGrabParamGetVoidPtr(NcGrab grab, const char* paramName,
    #        void** value);
    (:getParamVoidPtr, Grab, :ncGrabParamGetVoidPtr, Ptr{Void}),

    # int ncCamParamGetVoidPtr(NcCam cam, const char* paramName,
    #        void** value);
    (:getParamVoidPtr, Cam, :ncCamParamGetVoidPtr, Ptr{Void}))

    @eval function $m(handle::$H, name::Name)
        value = ref{$T}()
        @call($f, Status, ($H, Cstring, Ptr{$T}), handle, name, value)
        return value[]
    end

end

for (H, f) in (

    # int ncGrabParamGetStr(NcGrab grab, const char* paramName,
    #         char* outBuffer, int bufferSize);
    (Grab, :ncGrabParamGetStr),

    # int ncCamParamGetStr(NcCam cam, const char* paramName,
    #         char* outBuffer, int bufferSize);
    (Cam, :ncCamParamGetStr))

    @eval getParamStr(handle::$H, name::Name, buf::Array{Cchar}) =
        @call($f, Status, ($H, Cstring, Ptr{Cchar}, Cint),
              handle, name, buf, sizeof(buf))

end

for (H, f) in (

    # int ncGrabParamGetCallback(NcGrab grab, const char* paramName,
    #         void(**callback)(void*), void** data);
    (Grab, :ncGrabParamGetCallback),

    # int ncCamParamGetCallback(NcCam cam, const char* paramName,
    #         void(**callback)(void*), void** data);
    (Cam, :ncCamParamGetCallback))

    @eval function getParamCallback(handle::$H, name::Name)
        fct = Ref{Ptr{Void}}()
        data = Ref{Ptr{Void}}()
        @call($f, Status, ($H, Cstring, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}),
              handle, name, fct, data)
        return fct[], data[]
    end

end
