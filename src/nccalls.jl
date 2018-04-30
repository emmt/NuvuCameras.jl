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
# There are 337 non-deprecated functions in the Nüvü Camēras SDK.
# 295 have been currently interfaced.
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

function fetcharray(ptr::Ptr{T}, n::Integer) where {T}
    arr = Array{T}(n)
    ccall(:memcpy, Ptr{Void}, (Ptr{T}, Ptr{T}, Csize_t), arr, ptr, sizeof(arr))
    return arr
end

# Round timeout to nearest integer.
setTimeout(tgt::Union{Cam,Grab}, ms::Real) =
    setTimeout(tgt, rount(Cint, ms))

function writeFileHeader(currentFile::ImageSaved, dataType::HeaderDataType,
                         name::Name, value::Ptr{Void}, comment::Name)
    # int ncWriteFileHeader(NcImageSaved *currentFile,
    #         enum HeaderDataType dataType, const char *name,
    #         const void *value, const char *comment);
    @call(:ncWriteFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Void}, Cstring),
          currentFile, dataType, name, value, comment)
end

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

function readFileHeader(currentFile::ImageSaved, ::Type{Val{INT}}, name::Name)
    value = Ref{Cint}()
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cint}),
          currentFile, INT, name, value)
    return value[]
end

function readFileHeader(currentFile::ImageSaved, ::Type{Val{DOUBLE}}, name::Name)
    value = Ref{Cdouble}()
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cdouble}),
          currentFile, DOUBLE, name, value)
    return value[]
end

function readFileHeader(currentFile::ImageSaved, ::Type{Val{STRING}}, name::Name)
    buf = Array{Cchar}(1024) # FIXME: potential issue here
    @call(:ncReadFileHeader, Status,
          (ImageSaved, HeaderDataType, Cstring, Ptr{Cchar}),
          currentFile, INT, name, buf)
    buf[end] = 0
    return unsafe_string(pointer(buf))
end

function getFileFormat(image::ImageSaved)
    format = Ref{ImageFormat}()
    # int ncImageGetFileFormat(NcImageSaved* image, enum ImageFormat* format);
    @call(:ncImageGetFileFormat, Status, (ImageSaved, Ptr{ImageFormat}),
          image, format)
    return format[]
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

close(ctrlList::CtrlList) =
    # int ncControllerListFree(NcCtrlList ctrlList);
    @call(:ncControllerListFree, Status, (CtrlList, ), ctrlList)

for (jf, cf, T) in (

    # int ncControllerListGetSize(const NcCtrlList ctrlList, int * listSize);
    (:getSize, :ncControllerListGetSize, Cint),

    # int ncControllerListGetFreePortCount(const NcCtrlList ctrlList, int * portCount);
    (:getFreePortCount, :ncControllerListGetFreePortCount, Cint),

    # int ncControllerListGetPluginCount(const NcCtrlList ctrlList, int * listSize);
    (:getPluginCount, :ncControllerListGetPluginCount, Cint))

    @eval function $jf(ctrlList::CtrlList)
        value = Ref{$T}()
        @call($cf, Status, (CtrlList, Ptr{$T}), ctrlList, value)
        return value[]
    end

end

for (jf, cf, T) in (

    # int ncControllerListGetPortUnit(const NcCtrlList ctrlList, int index, int * unit);
    (:getPortUnit, :ncControllerListGetPortUnit, Cint),

    # int ncControllerListGetPortChannel(const NcCtrlList ctrlList, int index, int * channel);
    (:getPortChannel, :ncControllerListGetPortChannel, Cint),

    # int ncControllerListGetFreePortUnit(const NcCtrlList ctrlList, int index, int * unit);
    (:getFreePortUnit, :ncControllerListGetFreePortUnit, Cint),

    # int ncControllerListGetFreePortChannel(const NcCtrlList ctrlList, int index, int * channel);
    (:getFreePortChannel, :ncControllerListGetFreePortChannel, Cint),

    # int ncControllerListGetFreePortReason(const NcCtrlList ctrlList, int index, enum NcPortUnusedReason* reason);
    (:getFreePortReason, :ncControllerListGetFreePortReason, PortUnusedReason))

    @eval function $jf(ctrlList::CtrlList, index::Integer)
        value = Ref{$T}()
        @call($cf, Status, (CtrlList, Cint, Ptr{$T}),
              ctrlList, index, value)
        return value[]
    end

end

for (jf, cf) in (

    # int ncControllerListGetSerial(const NcCtrlList ctrlList, int index, char* serial, int serialSize);
    (:getSerial, :ncControllerListGetSerial),

    # int ncControllerListGetModel(const NcCtrlList ctrlList, int index, char* model, int modelSize);
    (:getModel, :ncControllerListGetModel),

    # int ncControllerListGetPortInterface(const NcCtrlList ctrlList, int index, char* acqInterface, int acqInterfaceSize);
    (:getPortInterface, :ncControllerListGetPortInterface),

    # int ncControllerListGetUniqueID(const NcCtrlList ctrlList, int index, char* uniqueID, int uniqueIDSize);
    (:getUniqueID, :ncControllerListGetUniqueID),

    # int ncControllerListGetDetectorType(const NcCtrlList ctrlList, int index, char* detectorType, int detectorTypeSize);
    (:getDetectorType, :ncControllerListGetDetectorType),

    # int ncControllerListGetFreePortInterface(const NcCtrlList ctrlList, int index, char* acqInterface, int acqInterfaceSize);
    (:getFreePortInterface, :ncControllerListGetFreePortInterface),

    # int ncControllerListGetFreePortUniqueID(const NcCtrlList ctrlList, int index, char* uniqueID, int uniqueIDSize);
    (:getFreePortUniqueID, :ncControllerListGetFreePortUniqueID),

    # int ncControllerListGetPluginName(const NcCtrlList ctrlList, int index, char* pluginName, int pluginNameSize);
    (:getPluginName, :ncControllerListGetPluginName))

    qcf = QuoteNode(cf)

    @eval function $jf(ctrlList::CtrlList, index::Integer)
        # Fisrt call to retrieve the number of bytes, then second call to
        # retrieve the contents.
        nbytes = @call($cf, Cint, (CtrlList, Cint, Ptr{Void}, Cint),
                       ctrlList, index, C_NULL, 0)
        if nbytes < 1
            # Assume index was out of bound.
            throw(NuvuCameraError($qcf, ERROR_OUT_OF_BOUNDS))
        end
        buf = Array{Cchar}(nbytes)
        ptr = pointer(buf)
        status = Status(@call($cf, Cint, (CtrlList, Cint, Ptr{Cchar}, Cint),
                              ctrlList, index, ptr, nbytes))
        if status != SUCCESS
            throw(NuvuCameraError($qcf, status))
        end
        return unsafe_string(ptr, nbytes - 1)
    end

end

for (jf, cf, T1, T2) in (

    # int ncControllerListGetFullSizeSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
    (:getFullSizeSize, :ncControllerListGetFullSizeSize, Cint, Cint),

    # int ncControllerListGetDetectorSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
    (:getDetectorSize, :ncControllerListGetDetectorSize, Cint, Cint))

    @eval function $jf(ctrlList::CtrlList, index::Integer)
        val1 = Ref{$T1}()
        val2 = Ref{$T2}()
        @call($cf, Status, (CtrlList, Cint, Ptr{$T1}, Ptr{$T2}),
              ctrlList, index, val1, val2)
        return val1[], val2[]
    end

end


#------------------------------------------------------------------------------
# GRAB FUNCTIONS

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

function open(::Type{Grab}, ctrlList::CtrlList, index::Integer, nbrBuffer::Integer)
    grab = Ref{Grab}()
    # int ncGrabOpenFromList(const NcCtrlList ctrlList, int index, int nbrBuffer, NcGrab* grab);
    @call(:ncGrabOpenFromList, Status, (CtrlList, Cint, Cint, Ptr{Grab}),
          ctrlList, index, nbrBuffer, grab)
    return grab[]
end

for (jf, cf) in (

    # int ncGrabClose(NcGrab grab);
    (:close, :ncGrabClose),

    # int ncGrabCancelEvent(NcGrab grab);
    (:cancelEvent, :ncGrabCancelEvent),

    # int ncGrabAbort(NcGrab grab);
    (:abort, :ncGrabAbort),

    # int ncGrabFlushReadQueues(NcGrab grab);
    (:flushReadQueues, :ncGrabFlushReadQueues),

    # int ncGrabStopSaveAcquisition(NcGrab grab);
    (:stopSaveAcquisition, :ncGrabStopSaveAcquisition),

    # int ncGrabCancelBiasCreation(NcGrab grab);
    (:cancelBiasCreation, :ncGrabCancelBiasCreation))

    @eval $jf(grab::Grab) = @call($cf, Status, (Grab, ), grab)

end

for (jf, Tj, cf, Tc) in (

    # int ncGrabStart(NcGrab grab, int nbrImages);
    (:start, Integer, :ncGrabStart, Cint),

    # int ncGrabSetHeartbeat(NcGrab grab, int timeMs);
    (:setHeartbeat, Integer, :ncGrabSetHeartbeat, Cint),

    # int ncGrabSetTimeout(NcGrab grab, int timeMs);
    (:setTimeout, Integer, :ncGrabSetTimeout, Cint),

    # int ncGrabSetTimestampMode(NcGrab grab, enum TimestampMode timestampMode);
    (:setTimestampMode, TimestampMode, :ncGrabSetTimestampMode, TimestampMode),

    # int ncGrabSetSerialTimeout(NcGrab grab, int serialTimeout);
    (:setSerialTimeout, Integer, :ncGrabSetSerialTimeout, Cint),

    # int ncGrabSetBaudrate(NcGrab grab, int baudrateSpeed);
    (:setBaudrate, Integer, :ncGrabSetBaudrate, Cint),

    # int ncGrabSaveImageSetCompressionType(NcGrab grab, enum ImageCompression compress);
    (:setSaveImageCompressionType, ImageCompression, :ncGrabSaveImageSetCompressionType, ImageCompression),

    # int ncGrabLoadParam(NcGrab grab, const char *saveName);
    (:loadParam, Name, :ncGrabLoadParam, Cstring),

    # int ncGrabResetTimer(NcGrab grab, double timeOffset);
    (:resetTimer, Real, :ncGrabResetTimer, Cdouble),

    # int ncGrabCreateBias(NcGrab grab, int nbrImages);
    (:createBias, Integer, :ncGrabCreateBias, Cint))

    @eval $jf(grab::Grab, value::$Tj) =
        @call($cf, Status, (Grab, $Tc), grab, value)

end

function open(::Type{ImageParams{Grab}})
    value = Ref{ImageParams{Grab}}()
    # int ncGrabOpenImageParams(ImageParams *imageParams);
    @call(:ncGrabOpenImageParams, Status, (Ptr{ImageParams}, ), value)
    return value[]
end

function getImageParams(grab::Grab, image::Ptr{Void},
                        imageParams::ImageParams{Grab})
    # int ncGrabGetImageParams(NcGrab grab, void* image, ImageParams imageParams);
    @call(:ncGrabGetImageParams, Status, (Grab, Ptr{Void}, ImageParams),
          grab, image, imageParams)
end

close(imageParams::ImageParams{Grab}) =
    # int ncGrabCloseImageParams(ImageParams imageParams);
    @call(:ncGrabCloseImageParams, Status, (ImageParams, ), imageParams)

for (jf, cf, T) in (

    # int ncGrabRead(NcGrab grab, NcImage** imageAcqu);
    (:raed, :ncGrabRead, Ptr{Image}),

    # int ncGrabGetNbrDroppedImages(NcGrab grab, int* nbrDroppedImages);
    (:getNbrDroppedImages, :ncGrabGetNbrDroppedImages, Cint),

    # int ncGrabGetNbrTimeout(NcGrab grab, int* nbrTimeout);
    (:getNbrTimeout, :ncGrabGetNbrTimeout, Cint),

    # int ncGrabGetTimeout(NcGrab grab, int* timeTimeout);
    (:getTimeout, :ncGrabGetTimeout, Cint),

    # int ncGrabGetHeartbeat(NcGrab grab, int *timeMs);
    (:gGetHeartbeat, :ncGrabGetHeartbeat, Cint),

    # int ncGrabGetSerialTimeout(NcGrab grab, int *serialTimeout);
    (:gGetSerialTimeout, :ncGrabGetSerialTimeout, Cint),

    # int ncGrabGetSerialUnreadBytes(NcGrab grab, int* numByte);
    (:gGetSerialUnreadBytes, :ncGrabGetSerialUnreadBytes, Cint),

    # int ncGrabNbrImagesAcquired(NcGrab grab, int *nbrImages);
    (:nbrImagesAcquired, :ncGrabNbrImagesAcquired, Cint),

    # int ncGrabSaveImageGetCompressionType(NcGrab grab, enum ImageCompression *compress);
    (:getSaveImageCompressionType, :ncGrabSaveImageGetCompressionType, ImageCompression))

    @eval function $jf(grab::Grab)
        value = Ref{$T}()
        @call($cf, Status, (Grab, Ptr{$T}), grab, value)
        return value[]
    end

end

# int ncGrabGetOverrun(NcGrab grab, int* overrunOccurred);
function getOverrun(grab::Grab)
    value = Ref{Cint}()
    @call(:ncGrabGetOverrun, Status, (Grab, Ptr{Cint}), grab, value)
    return (value[] != 0)
end

setSize(grab::Grab, width::Integer, height::Integer) =
    # int ncGrabSetSize(NcGrab grab, int width, int height);
    @call(:ncGrabSetSize, Status, (Grab, Cint, Cint), grab, width, height)

for (jf, cf, T1, T2) in (

    # int ncGrabGetSize(NcGrab grab, int* width, int* height);
    (:getSize, :ncGrabGetSize, Cint, Cint),

    # int ncGrabReadChronological(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
    (:readChronological, :ncGrabReadChronological, Ptr{Image}, Cint),

    # int ncGrabReadChronologicalNonBlocking(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, :ncGrabReadChronologicalNonBlocking, Ptr{Image}, Cint))

    @eval function $jf(grab::Grab)
        val1 = Ref{$T1}()
        val2 = Ref{$T2}()
        @call($cf, Status, (Grab, Ptr{$T1}, Ptr{$T2}),
              grab, val1, val2)
        return val1[], val2[]
    end

end

function saveImage(grab::Grab, image::Ptr{Image}, name::Name,
                   saveFormat::ImageFormat, overwrite::Bool)
    # int ncGrabSaveImage(NcGrab grab, const NcImage* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         int overwriteFlag);
    @call(:ncGrabSaveImage, Status,
          (Grab, Ptr{Image}, Cstring, ImageFormat, Cint),
          grab, image, name, saveFormat, overwrite)
end

function saveImage(grab::Grab, image::Ptr{Void}, name::Name,
                   imageFormat::ImageFormat, dataFormat::ImageDataType,
                   overwrite::Bool)
    # int ncGrabSaveImageEx(NcGrab grab, const void* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         enum ImageDataType dataFormat, int overwriteFlag);
    @call(:ncGrabSaveImageEx, Status,
          (Grab, Ptr{Void}, Cstring, ImageFormat, ImageDataType, Cint),
          grab, image, name, imageFormat, dataFormat, overwrite)
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

function startSaveAcquisition(grab::Grab, saveName::Name,
                              saveFormat::ImageFormat, imagesPerCubes::Integer,
                              nbrOfCubes::Integer, overwrite::Bool)
    # int ncGrabStartSaveAcquisition(NcGrab grab, const char *saveName,
    #         enum ImageFormat saveFormat,
    #         int imagesPerCubes, int nbrOfCubes,
    #         int overwriteFlag);
    @call(:ncGrabStartSaveAcquisition, Status,
          (Grab, Cstring, ImageFormat, Cint, Cint, Cint),
          grab, saveName, saveFormat, imagesPerCubes, nbrOfCubes, overwrite)
end


ncGrabSaveParam(grab::Grab, name::Name, overwrite::Bool) =
    # int ncGrabSaveParam(NcGrab grab, const char *saveName, int overwriteFlag);
    @call(:ncGrabSaveParam, Status, (Grab, Cstring, Cint),
          grab, name, overwrite)

#- # int ncGrabGetTimestampMode(NcGrab grab, int ctrlRequest, enum TimestampMode *timestampMode, int *gpsSignalValid);
#- ncGrabGetTimestampMode(grab::Grab, ctrlRequest::Cint, timestampMode::Ptr{TimestampMode}, gpsSignalValid::Ptr{Cint}) =
#-     @call(:ncGrabGetTimestampMode, Status,
#-           (Grab, Cint, Ptr{TimestampMode}, Ptr{Cint}),
#-           grab, ctrlRequest, timestampMode, gpsSignalValid)

#- # int ncGrabSetTimestampInternal(NcGrab grab, struct tm *dateTime, int nbrUs);
#- ncGrabSetTimestampInternal(grab::Grab, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
#-     @call(:ncGrabSetTimestampInternal, Status,
#-           (Grab, Ptr{TmStruct}, Cint),
#-           grab, dateTime, nbrUs)

#- # int ncGrabGetCtrlTimestamp(NcGrab grab, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
#- ncGrabGetCtrlTimestamp(grab::Grab, imageAcqu::Ptr{Image}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
#-     @call(:ncGrabGetCtrlTimestamp, Status,
#-           (Grab, Ptr{Image}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
#-           grab, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

#- # int ncGrabGetHostSystemTimestamp(NcGrab grab, NcImage* imageAcqu, double *hostSystemTimestamp);
#- ncGrabGetHostSystemTimestamp(grab::Grab, imageAcqu::Ptr{Image}, hostSystemTimestamp::Ptr{Cdouble}) =
#-     @call(:ncGrabGetHostSystemTimestamp, Status,
#-           (Grab, Ptr{Image}, Ptr{Cdouble}),
#-           grab, imageAcqu, hostSystemTimestamp)

#- # int ncGrabParamAvailable(NcGrab grab, enum Features param, int setting);
#- ncGrabParamAvailable(grab::Grab, param::Features, setting::Cint) =
#-     @call(:ncGrabParamAvailable, Status,
#-           (Grab, Features, Cint),
#-           grab, param, setting)

setEvent(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
    # int ncGrabSetEvent(NcGrab grab, NcCallbackFunc funcName, void* ncData);
    @call(:ncGrabSetEvent, Status, (Grab, Ptr{Void}, Ptr{Void}),
          grab, fct, data)

#- # int ncGrabSendSerialBinaryComm(NcGrab grab, const char *command, int length);
#- ncGrabSendSerialBinaryComm(grab::Grab, command::Ptr{Cchar}, length::Cint) =
#-     @call(:ncGrabSendSerialBinaryComm, Status,
#-           (Grab, Ptr{Cchar}, Cint),
#-           grab, command, length)

#- # int ncGrabWaitSerialCmd(NcGrab grab, int length, int* numByte);
#- ncGrabWaitSerialCmd(grab::Grab, length::Cint, numByte::Ptr{Cint}) =
#-     @call(:ncGrabWaitSerialCmd, Status,
#-           (Grab, Cint, Ptr{Cint}),
#-           grab, length, numByte)

#- # int ncGrabRecSerial(NcGrab grab, char *recBuffer, int length, int* numByte);
#- ncGrabRecSerial(grab::Grab, recBuffer::Ptr{Cchar}, length::Cint, numByte::Ptr{Cint}) =
#-     @call(:ncGrabRecSerial, Status,
#-           (Grab, Ptr{Cchar}, Cint, Ptr{Cint}),
#-           grab, recBuffer, length, numByte)


#- # int ncGrabGetVersion(NcGrab grab, enum VersionType versionType, char * version, int bufferSize);
#- ncGrabGetVersion(grab::Grab, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
#-     @call(:ncGrabGetVersion, Status,
#-           (Grab, VersionType, Ptr{Cchar}, Cint),
#-           grab, versionType, version, bufferSize)

#- # int ncGrabSetProcType(NcGrab grab, int type, int nbrImagesPc);
#- ncGrabSetProcType(grab::Grab, _type::Cint, nbrImagesPc::Cint) =
#-     @call(:ncGrabSetProcType, Status,
#-           (Grab, Cint, Cint),
#-           grab, _type, nbrImagesPc)

#- # int ncGrabGetProcType(NcGrab grab, int * type, int * nbrImagesPc);
#- ncGrabGetProcType(grab::Grab, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
#-     @call(:ncGrabGetProcType, Status,
#-           (Grab, Ptr{Cint}, Ptr{Cint}),
#-           grab, _type, nbrImagesPc)



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

function open(::Type{Cam}, ctrlList::CtrlList, index::Integer, nbrBuffer::Integer)
    cam = Ref{Cam}()
    # int ncCamOpenFromList(const NcCtrlList ctrlList, int index, int nbrBuffer, NcCam* cam);
    @call(:ncCamOpenFromList, Status, (CtrlList, Cint, Cint, Ptr{Cam}),
          ctrlList, index, nbrBuffer, cam)
    return cam[]
end

for (jf, cf) in (
    # int ncCamClose(NcCam cam);
    (:close, :ncCamClose),

    # int ncCamBeginAcquisition(NcCam cam);
    (:beginAcquisition, :ncCamBeginAcquisition),

    # int ncCamAbort(NcCam cam);
    (:abort, :ncCamAbort),

    # int ncCamFlushReadQueues(NcCam cam);
    (:flushReadQueues, :ncCamFlushReadQueues),

    # int ncCamStopSaveAcquisition(NcCam cam);
    (:stopSaveAcquisition, :ncCamStopSaveAcquisition),

    # int ncCamCancelEvent(NcCam cam);
    (:cancelEvent, :ncCamCancelEvent),

    # int ncCamMRoiApply(NcCam cam);
    (:applyMRoi, :ncCamMRoiApply),

    # int ncCamMRoiRollback(NcCam cam);
    (:rollbackMRoi, :ncCamMRoiRollback),

    # int ncCamCancelBiasCreation(NcCam cam);
    (:cancelBiasCreation, :ncCamCancelBiasCreation))

    @eval $jf(cam::Cam) = @call($cf, Status, (Cam, ), cam)

end


for (jf, Tj, cf, Tc) in (

    # int ncCamStart(NcCam cam, int nbrImages);
    (:start, Integer, :ncCamStart, Cint),

    # int ncCamPrepareAcquisition(NcCam cam, int nbrImages);
    (:prepareAcquisition, Integer, :ncCamPrepareAcquisition, Cint),

    # int ncCamSetHeartbeat(NcCam cam, int timeMs);
    (:setHeartbeat, Integer, :ncCamSetHeartbeat, Cint),

    # int ncCamResetTimer(NcCam cam, double timeOffset);
    (:resetTimer, Real, :ncCamResetTimer, Cdouble),

    # int ncCamSetTimeout(NcCam cam, int timeMs);
    (:setTimeout, Integer, :ncCamSetTimeout, Cint),

    # int ncCamSetTimestampMode(NcCam cam, enum TimestampMode timestampMode);
    (:setTimestampMode, TimestampMode, :ncCamSetTimestampMode, TimestampMode),

    # int ncCamReadUInt32(NcCam cam, uint32_t *image);
    (:read, Union{Ptr{UInt32},DenseMatrix{UInt32}}, :ncCamReadUInt32,
     Ptr{UInt32}),

    # int ncCamReadFloat(NcCam cam, float *image);
    (:read, Union{Ptr{Cfloat},DenseMatrix{Cfloat}}, :ncCamReadUInt32,
     Ptr{Cfloat}),

    # int ncCamLoadParam(NcCam cam, const char *saveName);
    (:loadParam, Name, :ncCamLoadParam, Cstring),

    # int ncCamSetReadoutMode(NcCam cam, int value);
    (:setReadoutMode, Integer, :ncCamSetReadoutMode, Cint),

    # int ncCamSetExposureTime(NcCam cam, double exposureTime);
    (:setExposureTime, Real, :ncCamSetExposureTime, Cdouble),

    # int ncCamSetWaitingTime(NcCam cam, double waitingTime);
    (:setWaitingTime, Real, :ncCamSetWaitingTime, Cdouble),

    # int ncCamSetShutterMode(NcCam cam, enum ShutterMode shutterMode);
    (:setShutterMode, ShutterMode, :ncCamSetShutterMode, ShutterMode),

    # int ncCamSetShutterPolarity(NcCam cam, enum ExtPolarity shutterPolarity);
    (:setShutterPolarity, ExtPolarity, :ncCamSetShutterPolarity, ExtPolarity),

    # int ncCamSetExternalShutter(NcCam cam,
    #         enum ExtShutter externalShutterPresence);
    (:setExternalShutter, ExtShutter, :ncCamSetExternalShutter, ExtShutter),

    # int ncCamSetExternalShutterMode(NcCam cam,
    #         enum ShutterMode externalShutterMode);
    (:setExternalShutterMode, ShutterMode, :ncCamSetExternalShutterMode,
     ShutterMode),

    # int ncCamSetExternalShutterDelay(NcCam cam,
    #         double externalShutterDelay);
    (:setExternalShutterDelay, Real, :ncCamSetExternalShutterDelay, Cdouble),

    # int ncCamSetFirePolarity(NcCam cam, enum ExtPolarity firePolarity);
    (:setFirePolarity, ExtPolarity, :ncCamSetFirePolarity, ExtPolarity),

    # int ncCamSetOutputMinimumPulseWidth(NcCam cam, double outputPulseWidth);
    (:setOutputMinimumPulseWidth, Real, :ncCamSetOutputMinimumPulseWidth,
     Cdouble),

    # int ncCamSetArmPolarity(NcCam cam, enum ExtPolarity armPolarity);
    (:setArmPolarity, ExtPolarity, :ncCamSetArmPolarity, ExtPolarity),

    # int ncCamSetCalibratedEmGain(NcCam cam, int calibratedEmGain);
    (:setCalibratedEmGain, Integer, :ncCamSetCalibratedEmGain, Cint),

    # int ncCamSetRawEmGain(NcCam cam, int rawEmGain);
    (:setRawEmGain, Integer, :ncCamSetRawEmGain, Cint),

    # int ncCamSetAnalogGain(NcCam cam, int analogGain);
    (:setAnalogGain, Integer, :ncCamSetAnalogGain, Cint),

    # int ncCamSetAnalogOffset(NcCam cam, int analogOffset);
    (:setAnalogOffset, Integer, :ncCamSetAnalogOffset, Cint),

    # int ncCamSetTargetDetectorTemp(NcCam cam, double targetDetectorTemp);
    (:setTargetDetectorTemp, Real, :ncCamSetTargetDetectorTemp, Cdouble),

    # int ncCamSetStatusPollRate(NcCam cam, int periodMs);
    (:setStatusPollRate, Integer, :ncCamSetStatusPollRate, Cint),

    # int ncCamSetSerialCarTime(NcCam cam, double serialCarTime);
    (:setSerialCarTime, Real, :ncCamSetSerialCarTime, Cdouble),

    # int ncCamDeleteMRoi(NcCam cam, int index);
    (:deleteMRoi, Integer, :ncCamDeleteMRoi, Cint))

    @eval $jf(cam::Cam, value::$Tj) =
        @call($cf, Status, (Cam, $Tc), cam, value)

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

function getImageParams(cam::Cam, image::Ptr{Void},
                        imageParams::ImageParams{Cam})
    # int ncCamGetImageParams(NcCam cam, void* image, ImageParams imageParams);
    @call(:ncCamGetImageParams, Status, (Cam, Ptr{Void}, ImageParams),
          cam, image, imageParams)
end

close(imageParams::ImageParams{Cam}) =
    # int ncCamCloseImageParams(ImageParams imageParams);
    @call(:ncCamCloseImageParams, Status, (ImageParams, ), imageParams)

for (jf, cf, T) in (

    # int ncCamReadUInt32Chronological(NcCam cam, uint32_t* imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronological, :ncCamReadUInt32Chronological, UInt32),

    # int ncCamReadFloatChronological(NcCam cam, float* imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronological, :ncCamReadFloatChronological, Cfloat),

    # int ncCamReadUInt32ChronologicalNonBlocking(NcCam cam,
    #         uint32_t* imageAcqu, int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, :ncCamReadUInt32ChronologicalNonBlocking,
     UInt32),

    # int ncCamReadFloatChronologicalNonBlocking(NcCam cam, float* imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, :ncCamReadFloatChronologicalNonBlocking,
     Cfloat))

    @eval function $jf(cam::Cam, img::Union{Ptr{$T},DenseMatrix{$T}})
        nskip = Ref{Cint}()
        @call($cf, Status, (Cam, Ptr{$T}, Ptr{Cint}),
              cam, img, nskip)
        return nskip[]
    end

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

for (jf, cf, T) in (
    # int ncCamRead(NcCam cam, NcImage** imageAcqu);
    (:read, :ncCamRead, Ptr{Image}),

    # int ncCamGetHeartbeat(NcCam cam, int *timeMs);
    (:getHeartbeat, :ncCamGetHeartbeat, Cint),

    # int ncCamGetNbrDroppedImages(NcCam cam, int* nbrDroppedImages);
    (:getNbrDroppedImages, :ncCamGetNbrDroppedImages, Cint),

    # int ncCamGetNbrTimeout(NcCam cam, int* nbrTimeout);
    (:getNbrTimeout, :ncCamGetNbrTimeout, Cint),

    # int ncCamGetTimeout(NcCam cam, int* timeTimeout);
    (:getTimeout, :ncCamGetTimeout, Cint),

    # int ncCamGetNbrReadoutModes(NcCam cam, int* nbrReadoutMode);
    (:getNbrReadoutModes, :ncCamGetNbrReadoutModes, Cint),

    # int ncCamGetReadoutTime(NcCam cam, double *time);
    (:getReadoutTime, :ncCamGetReadoutTime, Cdouble),

    # int ncCamGetOverscanLines(NcCam cam, int *overscanLines);
    (:getOverscanLines, :ncCamGetOverscanLines, Cint),

    # int ncCamGetFrameLatency(NcCam cam, int *frameLatency);
    (:getFrameLatency, :ncCamGetFrameLatency, Cint),

    # int ncCamGetDetectorTemp(NcCam cam, double* detectorTemp);
    (:getDetectorTemp, :ncCamGetDetectorTemp, Cdouble),

    # int ncCamGetDetectorType(NcCam cam, enum DetectorType *type);
    (:getDetectorType, :ncCamGetDetectorType, DetectorType),

    # int ncCamGetMRoiCount(NcCam cam, int * count);
    (:getMRoiCount, :ncCamGetMRoiCount, Cint),

    # int ncCamGetMRoiCountMax(NcCam cam, int * count);
    (:getMRoiCountMax, :ncCamGetMRoiCountMax, Cint),

    # int ncCamGetStatusPollRate(NcCam cam, int * periodMs);
    (:getStatusPollRate, :ncCamGetStatusPollRate, Cint))

    @eval function $jf(cam::Cam)
        value = Ref{$T}()
        @call($cf, Status, (Cam, Ptr{$T}), cam, value)
        return value[]
    end

end

# int ncCamGetOverrun(NcCam cam, int* overrunOccurred);
function getOverrun(cam::Cam)
    value = Ref{Cint}()
    @call(:ncCamGetOverrun, Status, (Cam, Ptr{Cint}), cam, value)
    return (value[] != 0)
end

for (jf, cf, T1, T2) in (

    # int ncCamGetSize(NcCam cam, int *width, int *height);
    (:getSize, :ncCamGetSize, Cint, Cint),

    # int ncCamGetMaxSize(NcCam cam, int *width, int *height);
    (:getMaxSize, :ncCamGetMaxSize, Cint, Cint),

    # int ncCamReadChronological(NcCam cam, NcImage** imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronological, :ncCamReadChronological, Ptr{Image}, Cint),

    # int ncCamReadChronologicalNonBlocking(NcCam cam, NcImage **imageAcqu,
    #         int* nbrImagesSkipped);
    (:readChronologicalNonBlocking, :ncCamReadChronologicalNonBlocking,
     Ptr{Image}, Cint),

    # int ncCamGetCalibratedEmGainRange(NcCam cam, int* calibratedEmGainMin,
    #         int* calibratedEmGainMax);
    (:getCalibratedEmGainRange, :ncCamGetCalibratedEmGainRange, Cint, Cint),

    # int ncCamGetCalibratedEmGainTempRange(NcCam cam,
    #         double* calibratedEmGainTempMin,
    #         double* calibratedEmGainTempMax);
    (:getCalibratedEmGainTempRange, :ncCamGetCalibratedEmGainTempRange,
     Cdouble, Cdouble),

    # int ncCamGetRawEmGainRange(NcCam cam, int* rawEmGainMin,
    #         int* rawEmGainMax);
    (:getRawEmGainRange, :ncCamGetRawEmGainRange, Cint, Cint),

    # int ncCamGetAnalogGainRange(NcCam cam, int* analogGainMin,
    #         int* analogGainMax);
    (:getAnalogGainRange, :ncCamGetAnalogGainRange, Cint, Cint),

    # int ncCamGetAnalogOffsetRange(NcCam cam, int* analogOffsetMin,
    #         int* analogOffsetMax);
    (:getAnalogOffsetRange, :ncCamGetAnalogOffsetRange, Cint, Cint),

    # int ncCamGetTargetDetectorTempRange(NcCam cam,
    #         double *targetDetectorTempMin, double *targetDetectorTempMax);
    (:getTargetDetectorTempRange, :ncCamGetTargetDetectorTempRange,
     Cdouble, Cdouble),

    # int ncCamGetBinningMode(NcCam cam, int *binXValue, int *binYValue);
    (:getBinningMode, :ncCamGetBinningMode, Cint, Cint),

    # int ncCamGetActiveRegion(NcCam cam, int *width, int *height);
    (:getActiveRegion, :ncCamGetActiveRegion, Cint, Cint),

    # int ncCamGetFullCCDSize(NcCam cam, int *width, int *height);
    (:getFullCCDSize, :ncCamGetFullCCDSize, Cint, Cint))

    @eval function $jf(cam::Cam)
        val1 = Ref{$T1}()
        val2 = Ref{$T2}()
        @call($cf, Status, (Cam, Ptr{$T1}, Ptr{$T2}), cam, va1, val2)
        return val1[], val2[]
    end

end

for (cf, T) in (
    # int ncCamSaveImage(NcCam cam, const NcImage* imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         const char* addComments, int overwriteFlag);
    (:ncCamSaveImage, Image),
    # int ncCamSaveUInt32Image(NcCam cam, const uint32_t *imageNc,
    #         const char *saveName, enum ImageFormat saveFormat,
    #         const char *addComments, int overwriteFlag);
    (:ncCamSaveUInt32Image, UInt32),

    # int ncCamSaveFloatImage(NcCam cam, const float *imageNc,
    #         const char *saveName, enum ImageFormat saveFormat,
    #         const char *addComments, int overwriteFlag);
    (:ncCamSaveFloatImage, Cfloat))

    @eval function saveImage(cam::Cam, img::Ptr{$T},
                             name::Name, saveFormat::ImageFormat,
                             comments::Name, overwrite::Bool)
        @call($cf, Status,
              (Cam, Ptr{$T}, Cstring, ImageFormat, Cstring, Cint),
              cam, img, name, saveFormat, comments, overwrite)
    end

end

function saveImage(cam::Cam, image::Ptr{Void}, name::Name,
                   saveFormat::ImageFormat, dataFormat::ImageDataType,
                   comments::Name, overwrite::Bool) <:PixelTypes
    # int ncCamSaveImageEx(NcCam cam, const void * imageNc,
    #         const char* saveName, enum ImageFormat saveFormat,
    #         enum ImageDataType dataFormat,
    #         const char* addComments, int overwriteFlag);
    @call(:ncCamSaveImageEx, Status,
          (Cam, Ptr{Void}, Cstring, ImageFormat, ImageDataType, Cstring, Cint),
          cam, image, name, saveFormat, dataFormat, comments, overwrite)
end

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

function startSaveAcquisition(cam::Cam, saveName::Cstring,
                              saveFormat::ImageFormat, imagesPerCubes::Integer,
                              addComments::Cstring, nbrOfCubes::Integer,
                              overwrite::Bool)
    # int ncCamStartSaveAcquisition(NcCam cam, const char *saveName,
    #         enum ImageFormat saveFormat, int imagesPerCubes,
    #         const char *addComments, int nbrOfCubes, int overwriteFlag);
    @call(:ncCamStartSaveAcquisition, Status,
          (Cam, Cstring, ImageFormat, Cint, Cstring, Cint, Cint),
          cam, saveName, saveFormat, imagesPerCubes, addComments,
          nbrOfCubes, overwriteFlag)
end



#- # int ncCamSaveImageSetCompressionType(NcCam cam, enum ImageCompression compress);
#- ncCamSaveImageSetCompressionType(cam::Cam, compress::ImageCompression) =
#-     @call(:ncCamSaveImageSetCompressionType, Status,
#-           (Cam, ImageCompression),
#-           cam, compress)

#- # int ncCamSaveImageGetCompressionType(NcCam cam, enum ImageCompression *compress);
#- ncCamSaveImageGetCompressionType(cam::Cam, compress::Ptr{ImageCompression}) =
#-     @call(:ncCamSaveImageGetCompressionType, Status,
#-           (Cam, Ptr{ImageCompression}),
#-           cam, compress)

setEvent(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
# int ncCamSetEvent(NcCam cam, NcCallbackFunc funcName, void *ncData);
    @call(:ncCamSetEvent, Status, (Cam, Ptr{Void}, Ptr{Void}),
          cam, fct, data)


function getTimestampMode(cam::Cam, cameraRequest::Bool)
    timestampMode = Ref{TimestampMode}()
    gpsSignalValid = Ref{Cint}()
    # int ncCamGetTimestampMode(NcCam cam, int cameraRequest,
    #         enum TimestampMode *timestampMode,
    #         int *gpsSignalValid);
    @call(:ncCamGetTimestampMode, Status,
          (Cam, Cint, Ptr{TimestampMode}, Ptr{Cint}),
          cam, cameraRequest, timestampMode, gpsSignalValid)
    return timestampMode[], (gpsSignalValid[] != 0)
end

#- # int ncCamSetTimestampInternal(NcCam cam, struct tm *dateTime, int nbrUs);
#- ncCamSetTimestampInternal(cam::Cam, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
#-     @call(:ncCamSetTimestampInternal, Status,
#-           (Cam, Ptr{TmStruct}, Cint),
#-           cam, dateTime, nbrUs)

#- # int ncCamGetCtrlTimestamp(NcCam cam, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
#- ncCamGetCtrlTimestamp(cam::Cam, imageAcqu::Ptr{Image}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
#-     @call(:ncCamGetCtrlTimestamp, Status,
#-           (Cam, Ptr{Image}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
#-           cam, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

#- # int ncCamGetHostSystemTimestamp(NcCam cam, NcImage* imageAcqu, double *hostSystemTimestamp);
#- ncCamGetHostSystemTimestamp(cam::Cam, imageAcqu::Ptr{Image}, hostSystemTimestamp::Ptr{Cdouble}) =
#-     @call(:ncCamGetHostSystemTimestamp, Status,
#-           (Cam, Ptr{Image}, Ptr{Cdouble}),
#-           cam, imageAcqu, hostSystemTimestamp)

#- # int ncCamParamAvailable(NcCam cam, enum Features param, int setting);
#- ncCamParamAvailable(cam::Cam, param::Features, setting::Cint) =
#-     @call(:ncCamParamAvailable, Status,
#-           (Cam, Features, Cint),
#-           cam, param, setting)

#- # int ncCamSaveParam(NcCam cam, const char* saveName, int overwriteFlag);
#- ncCamSaveParam(cam::Cam, saveName::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveParam, Status,
#-           (Cam, Ptr{Cchar}, Cint),
#-           cam, saveName, overwriteFlag)

#- # int ncCamGetCurrentReadoutMode(NcCam cam, int* readoutMode, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
#- ncCamGetCurrentReadoutMode(cam::Cam, readoutMode::Ptr{Cint}, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
#-     @call(:ncCamGetCurrentReadoutMode, Status,
#-           (Cam, Ptr{Cint}, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
#-           cam, readoutMode, ampliType, ampliString, vertFreq, horizFreq)

#- # int ncCamGetReadoutMode(NcCam cam, int number, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
#- ncCamGetReadoutMode(cam::Cam, number::Cint, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
#-     @call(:ncCamGetReadoutMode, Status,
#-           (Cam, Cint, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
#-           cam, number, ampliType, ampliString, vertFreq, horizFreq)

#- # int ncCamGetAmpliTypeAvail(NcCam cam, enum Ampli ampli, int *number);
#- ncCamGetAmpliTypeAvail(cam::Cam, ampli::Ampli, number::Ptr{Cint}) =
#-     @call(:ncCamGetAmpliTypeAvail, Status,
#-           (Cam, Ampli, Ptr{Cint}),
#-           cam, ampli, number)

#- # int ncCamGetFreqAvail(NcCam cam, enum Ampli ampli, int ampliNo, int *vertFreq, int *horizFreq, int* readoutModeNo);
#- ncCamGetFreqAvail(cam::Cam, ampli::Ampli, ampliNo::Cint, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}, readoutModeNo::Ptr{Cint}) =
#-     @call(:ncCamGetFreqAvail, Status,
#-           (Cam, Ampli, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
#-           cam, ampli, ampliNo, vertFreq, horizFreq, readoutModeNo)


for (jf, cf, T) in (

    # int ncCamGetExposureTime(NcCam cam, int cameraRequest,
    #         double* exposureTime);
    (:getExposureTime, :ncCamGetExposureTime, Cdouble),

    # int ncCamGetWaitingTime(NcCam cam, int cameraRequest,
    #         double* waitingTime);
    (:getWaitingTime, :ncCamGetWaitingTime, Cdouble),

    # int ncCamGetShutterMode(NcCam cam, int cameraRequest,
    #         enum ShutterMode* shutterMode);
    (:getShutterMode, :ncCamGetShutterMode, ShutterMode),

    # int ncCamGetShutterPolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* shutterPolarity);
    (:getShutterPolarity, :ncCamGetShutterPolarity, ExtPolarity),

    # int ncCamGetExternalShutter(NcCam cam, int cameraRequest,
    #         enum ExtShutter* externalShutterPresence);
    (:getExternalShutter, :ncCamGetExternalShutter, ExtShutter),

    # int ncCamGetExternalShutterMode(NcCam cam, int cameraRequest,
    #         enum ShutterMode* externalShutterMode);
    (:getExternalShutterMode, :ncCamGetExternalShutterMode, ShutterMode),

    # int ncCamGetExternalShutterDelay(NcCam cam, int cameraRequest,
    #         double* externalShutterDelay);
    (:getExternalShutterDelay, :ncCamGetExternalShutterDelay, Cdouble),

    # int ncCamGetFirePolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* firePolarity);
    (:getFirePolarity, :ncCamGetFirePolarity, ExtPolarity),

    # int ncCamGetOutputMinimumPulseWidth(NcCam cam, int cameraRequest,
    #         double *outputPulseWidth);
    (:getOutputMinimumPulseWidth, :ncCamGetOutputMinimumPulseWidth, Cdouble),

    # int ncCamGetArmPolarity(NcCam cam, int cameraRequest,
    #         enum ExtPolarity* armPolarity);
    (:getArmPolarity, :ncCamGetArmPolarity, ExtPolarity),

    # int ncCamGetCalibratedEmGain(NcCam cam, int cameraRequest,
    #         int *calibratedEmGain);
    (:getCalibratedEmGain, :ncCamGetCalibratedEmGain, Cint),

    # int ncCamGetRawEmGain(NcCam cam, int cameraRequest, int* rawEmGain);
    (:getRawEmGain, :ncCamGetRawEmGain, Cint),

    # int ncCamGetAnalogGain(NcCam cam, int cameraRequest, int* analogGain);
    (:getAnalogGain, :ncCamGetAnalogGain, Cint),

    # int ncCamGetAnalogOffset(NcCam cam, int cameraRequest,
    #         int* analogOffset);
    (:getAnalogOffset, :ncCamGetAnalogOffset, Cint),

    # int ncCamGetTargetDetectorTemp(NcCam cam, int cameraRequest,
    #         double* targetDetectorTemp);
    (:getTargetDetectorTemp, :ncCamGetTargetDetectorTemp, Cdouble),

    # int ncCamGetSerialCarTime(NcCam cam, int cameraRequest,
    #         double* serialCarTime);
    (:getSerialCarTime, :ncCamGetSerialCarTime, Cdouble))

    @eval function $jf(cam::Cam, req::Bool)
        value = Ref{$T}()
        @call($cf, Status, (Cam, Cint, Ptr{$T}), cam, req, value)
        return value[]
    end

end

#- # int ncCamSetTriggerMode(NcCam cam, enum TriggerMode triggerMode, int nbrImages);
#- ncCamSetTriggerMode(cam::Cam, triggerMode::TriggerMode, nbrImages::Cint) =
#-     @call(:ncCamSetTriggerMode, Status,
#-           (Cam, TriggerMode, Cint),
#-           cam, triggerMode, nbrImages)

#- # int ncCamGetTriggerMode(NcCam cam, int cameraRequest, enum TriggerMode* triggerMode, int* nbrImagesPerTrig);
#- ncCamGetTriggerMode(cam::Cam, cameraRequest::Cint, triggerMode::Ptr{TriggerMode}, nbrImagesPerTrig::Ptr{Cint}) =
#-     @call(:ncCamGetTriggerMode, Status,
#-           (Cam, Cint, Ptr{TriggerMode}, Ptr{Cint}),
#-           cam, cameraRequest, triggerMode, nbrImagesPerTrig)

#- # int ncCamGetComponentTemp(NcCam cam, enum NcTemperatureType temp, double * value);
#- ncCamGetComponentTemp(cam::Cam, temp::TemperatureType, value::Ptr{Cdouble}) =
#-     @call(:ncCamGetComponentTemp, Status,
#-           (Cam, TemperatureType, Ptr{Cdouble}),
#-           cam, temp, value)

#- # int ncCamGetSerialNumber(NcCam cam, char *sn);
#- ncCamGetSerialNumber(cam::Cam, sn::Ptr{Cchar}) =
#-     @call(:ncCamGetSerialNumber, Status,
#-           (Cam, Ptr{Cchar}),
#-           cam, sn)

#- # int ncCamDetectorTypeEnumToString(enum DetectorType detectorType, const char** str);
#- ncCamDetectorTypeEnumToString(detectorType::DetectorType, str::Ptr{Ptr{Cchar}}) =
#-     @call(:ncCamDetectorTypeEnumToString, Status,
#-           (DetectorType, Ptr{Ptr{Cchar}}),
#-           detectorType, str)

#- # int ncCamSetBinningMode(NcCam cam, int binXValue, int binYValue);
#- ncCamSetBinningMode(cam::Cam, binXValue::Cint, binYValue::Cint) =
#-     @call(:ncCamSetBinningMode, Status,
#-           (Cam, Cint, Cint),
#-           cam, binXValue, binYValue)

#- # int ncCamSetMRoiSize(NcCam cam, int index, int width, int height);
#- ncCamSetMRoiSize(cam::Cam, index::Cint, width::Cint, height::Cint) =
#-     @call(:ncCamSetMRoiSize, Status,
#-           (Cam, Cint, Cint, Cint),
#-           cam, index, width, height)

#- # int ncCamGetMRoiSize(NcCam cam, int index, int * width, int * height);
#- ncCamGetMRoiSize(cam::Cam, index::Cint, width::Ptr{Cint}, height::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiSize, Status,
#-           (Cam, Cint, Ptr{Cint}, Ptr{Cint}),
#-           cam, index, width, height)

#- # int ncCamSetMRoiPosition(NcCam cam, int index, int offsetX, int offsetY);
#- ncCamSetMRoiPosition(cam::Cam, index::Cint, offsetX::Cint, offsetY::Cint) =
#-     @call(:ncCamSetMRoiPosition, Status,
#-           (Cam, Cint, Cint, Cint),
#-           cam, index, offsetX, offsetY)

#- # int ncCamGetMRoiPosition(NcCam cam, int index, int * offsetX, int * offsetY);
#- ncCamGetMRoiPosition(cam::Cam, index::Cint, offsetX::Ptr{Cint}, offsetY::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiPosition, Status,
#-           (Cam, Cint, Ptr{Cint}, Ptr{Cint}),
#-           cam, index, offsetX, offsetY)

#- # int ncCamAddMRoi(NcCam cam, int offsetX, int offsetY, int width, int height);
#- ncCamAddMRoi(cam::Cam, offsetX::Cint, offsetY::Cint, width::Cint, height::Cint) =
#-     @call(:ncCamAddMRoi, Status,
#-           (Cam, Cint, Cint, Cint, Cint),
#-           cam, offsetX, offsetY, width, height)

for (jf, cf) in (

    # int ncCamGetMRoiInputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
    (:getMRoiInputRegion, :ncCamGetMRoiInputRegion),

    # int ncCamGetMRoiOutputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
    (:getMRoiOutputRegion, :ncCamGetMRoiOutputRegion))

    @eval function $jf(params::ImageParams{Cam}, index::Integer)
        offsetX = Ref{Cint}()
        offsetY = Ref{Cint}()
        width = Ref{Cint}()
        height = Ref{Cint}()
        @call($cf, Status,
              (ImageParams, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
              params, index, offsetX, offsetY, width, height)
        return offsetX[], offsetY[], width[], height[]
    end

end

#- # int ncCamGetMRoiRegionCount(ImageParams params, int * count);
#- ncCamGetMRoiRegionCount(params::ImageParams, count::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiRegionCount, Status,
#-           (ImageParams, Ptr{Cint}),
#-           params, count)

#- # int ncCamMRoiHasChanges(NcCam cam, int * hasChanges);
#- ncCamMRoiHasChanges(cam::Cam, hasChanges::Ptr{Cint}) =
#-     @call(:ncCamMRoiHasChanges, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, hasChanges)

#- # int ncCamMRoiCanApplyWithoutStop(NcCam cam, int * nonStop);
#- ncCamMRoiCanApplyWithoutStop(cam::Cam, nonStop::Ptr{Cint}) =
#-     @call(:ncCamMRoiCanApplyWithoutStop, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, nonStop)

#- # int ncCamGetVersion(NcCam cam, enum VersionType versionType, char * version, int bufferSize);
#- ncCamGetVersion(cam::Cam, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
#-     @call(:ncCamGetVersion, Status,
#-           (Cam, VersionType, Ptr{Cchar}, Cint),
#-           cam, versionType, version, bufferSize)

#- # int ncCamNbrImagesAcquired(NcCam cam, int *nbrImages);
#- ncCamNbrImagesAcquired(cam::Cam, nbrImages::Ptr{Cint}) =
#-     @call(:ncCamNbrImagesAcquired, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, nbrImages)

#- # int ncCamGetSafeShutdownTemperature(NcCam cam, double *safeTemperature, int *dontCare);
#- ncCamGetSafeShutdownTemperature(cam::Cam, safeTemperature::Ptr{Cdouble}, dontCare::Ptr{Cint}) =
#-     @call(:ncCamGetSafeShutdownTemperature, Status,
#-           (Cam, Ptr{Cdouble}, Ptr{Cint}),
#-           cam, safeTemperature, dontCare)

#------------------------------------------------------------------------------
# CALLBACKS

for (H, jf, cf) in (

    # Frame grabber callbacks.

    # int ncGrabSaveImageSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Grab, :setWriteHeaderCallback, :ncGrabSaveImageSetHeaderCallback),

    # int ncGrabSaveImageWriteCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
    (Grab, :setWriteImageCallback, :ncGrabSaveImageWriteCallback),

    # int ncGrabSaveImageCloseCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int fileNo, void *data), void *data);
    (Grab, :setCloseImageCallback, :ncGrabSaveImageCloseCallback),

    # int ncGrabSaveParamSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Grab, :setSaveParamHeaderCallback, :ncGrabSaveParamSetHeaderCallback),

    # int ncGrabLoadParamSetHeaderCallback(NcGrab grab,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Grab, :setLoadParamHeaderCallback, :ncGrabLoadParamSetHeaderCallback),

    # int ncGrabCreateBiasNewImageCallback(NcGrab grab,
    #         void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
    (Grab, :setCreateBiasCallback, :ncGrabCreateBiasNewImageCallback),


    # Camera callbacks.

    # int ncCamReadyToClose(NcCam cam, void (*fct)(NcCam cam, void *data),
    #         void *data);
    (Cam, :readyToClose, :ncCamReadyToClose),

    # int ncCamSaveImageSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcCam cam, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Cam, :setWriteHeaderCallback, :ncCamSaveImageSetHeaderCallback),

    # int ncCamSaveImageWriteCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int imageNo, void *data), void *data);
    (Cam, :setWriteImageCallback, :ncCamSaveImageWriteCallback),

    # int ncCamSaveImageCloseCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int fileNo, void *data), void *data);
    (Cam, :setCloseImageCallback, :ncCamSaveImageCloseCallback),

    # int ncCamSaveParamSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Cam, :setSaveParamHeaderCallback, :ncCamSaveParamSetHeaderCallback),

    # int ncCamLoadParamSetHeaderCallback(NcCam cam,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Cam, :setLoadParamHeaderCallback, :ncCamLoadParamSetHeaderCallback),

    # int ncCamCreateBiasNewImageCallback(NcCam cam,
    #         void (*fct)(NcCam cam, int imageNo, void *data), void *data);
    (Cam, :setCreateBiasCallback, :ncCamCreateBiasNewImageCallback),

    # int ncCamSetOnStatusAlertCallback(NcCam cam,
    #         void (*fct)(NcCam cam, void* data, int errorCode,
    #                     const char* errorString), void* data);
    (Cam, :setOnStatusAlertCallback, :ncCamSetOnStatusAlertCallback),

    # int ncCamSetOnStatusUpdateCallback(NcCam cam,
    #         void (*fct)(NcCam cam, void* data), void* data);
    (Cam, :setOnStatusUpdateCallback, :ncCamSetOnStatusUpdateCallback),


    # Processing callbacks.

    # int ncProcSaveSetHeaderCallback(NcProc ctx,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Proc, :setSaveHeaderCallback, :ncProcSaveSetHeaderCallback),

    # int ncProcLoadSetHeaderCallback(NcProc ctx,
    #         void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data),
    #         void *data);
    (Proc, :setLoadHeaderCallback, :ncProcLoadSetHeaderCallback))

    @eval $jf(handle::$H, fct::Ptr{Void}, data::Ptr{Void}) =
        @call($cf, Status, ($H, Ptr{Void}, Ptr{Void}), handle, fct, data)

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

close(solutionSet::CropModeSolutions) =
    # int ncCropModeSolutionsClose(NcCropModeSolutions solutionSet);
    @call(:ncCropModeSolutionsClose, Status, (CropModeSolutions,), solutionSet)

#------------------------------------------------------------------------------

#- # int ncCamCreateBias(NcCam cam, int nbrImages, enum ShutterMode biasShuttermode);
#- ncCamCreateBias(cam::Cam, nbrImages::Cint, biasShuttermode::ShutterMode) =
#-     @call(:ncCamCreateBias, Status,
#-           (Cam, Cint, ShutterMode),
#-           cam, nbrImages, biasShuttermode)

#- # int ncCamGetProcType(NcCam cam, int * type, int * nbrImagesPc);
#- ncCamGetProcType(cam::Cam, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
#-     @call(:ncCamGetProcType, Status,
#-           (Cam, Ptr{Cint}, Ptr{Cint}),
#-           cam, _type, nbrImagesPc)

#- # int ncCamSetProcType(NcCam cam, int type, int nbrImagesPc);
#- ncCamSetProcType(cam::Cam, _type::Cint, nbrImagesPc::Cint) =
#-     @call(:ncCamSetProcType, Status,
#-           (Cam, Cint, Cint),
#-           cam, _type, nbrImagesPc)



#------------------------------------------------------------------------------
# PROCESSING FUNCTIONS

function open(::Type{Proc}, width::Integer, height::Integer)
    procCtx = Ref{Proc}()
    # int ncProcOpen(int width, int height, NcProc* procCtx);
    @call(:ncProcOpen, Status, (Cint, Cint, Ptr{Proc}), width, height, procCtx)
    return procCtx[]
end

for (jf, cf) in (

    # int ncProcClose(NcProc ctx);
    (:close, :ncProcClose),

    # int ncProcComputeBias(NcProc ctx);
    (:computeBias, :ncProcComputeBias),

    # int ncProcEmptyStack(NcProc ctx);
    (:emptyStack, :ncProcEmptyStack))

    @eval $jf(ctx::Proc) = @call($cf, Status, (Proc,), ctx)

end

resize(ctx::Proc, width::Integer, height::Integer) =
# int ncProcResize(NcProc ctx, int width, int height);
    @call(:ncProcResize, Status, (Proc, Cint, Cint), ctx, width, height)

for (jf, Tj, cf, Tc) in (
    # int ncProcAddBiasImage(NcProc ctx, NcImage *bias);
    (:addBiasImage, Ptr{Image}, :ncProcAddBiasImage, Ptr{Image}),

    # int ncProcSetProcType(NcProc ctx, int type);
    (:setType, Integer, :ncProcSetProcType, Cint),

    # int ncProcProcessDataImageInPlace(NcProc ctx, NcImage *image);
    (:processDataImageInPlace, Ptr{Image}, :ncProcProcessDataImageInPlace, Ptr{Image}),

    # int ncProcAddDataImage(NcProc ctx, NcImage *image);
    (:addDataImage, Ptr{Image}, :ncProcAddDataImage, Ptr{Image}),

    # int ncProcReleaseImage(NcProc ctx, NcImage *image);
    (:releaseImage, Ptr{Image}, :ncProcReleaseImage, Ptr{Image}),

    # int ncProcSetBiasClampLevel(NcProc ctx, int biasClampLevel);
    (:setBiasClampLevel, Integer, :ncProcSetBiasClampLevel, Cint),

    # int ncProcSetOverscanLines(NcProc ctx, int overscanLines);
    (:setOverscanLines, Integer, :ncProcSetOverscanLines, Cint))

    @eval $jf(ctx::Proc, value::$Tj) =
        @call($cf, Status, (Proc, $Tc), ctx, value)

end

for (jf, cf, T) in (

    # int ncProcGetProcType(NcProc ctx, int *type);
    (:getType, :ncProcGetProcType, Cint),

    # int ncProcGetImage(NcProc ctx, NcImage** image);
    (:getImage, :ncProcGetImage, Ptr{Image}),

    # int ncProcGetBiasClampLevel(NcProc ctx, int* biasLevel);
    (:getBiasClampLevel, :ncProcGetBiasClampLevel, Cint),

    # int ncProcGetOverscanLines(NcProc ctx, int *overscanLines);
    (:getOverscanLines, :ncProcGetOverscanLines, Cint))

    @eval function $jf(ctx::Proc)
        value = Ref{$T}()
        @call($jf, Status, (Proc, Ptr{$T}), ctx, value)
        return value[]
    end

end

processDataImageInPlaceForceType(ctx::Proc, image::Ptr{Image}, procType::Integer) =
    # int ncProcProcessDataImageInPlaceForceType(NcProc ctx, NcImage *image, int procType);
    @call(:ncProcProcessDataImageInPlaceForceType, Status,
          (Proc, Ptr{Image}, Cint), ctx, image, procType)

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

close(statsCtx::StatsCtx) =
    # int ncStatsClose(NcStatsCtx *statsCtx);
    @call(:ncStatsClose, Status, (StatsCtx, ), statsCtx)

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

    cf = (:ncCamStatsAddRegion,
          :ncGrabStatsAddRegion,
          :ncStatsAddRegion)[i]

    @eval function addRegion(handle::$T, regionWidth::Integer,
                             regionHeight::Integer)
        regionIndex = Ref{Cint}()
        @call($cf, Status, ($T, Cint, Cint, Ptr{Cint}),
              handle, regionWidth, regionHeight, regionIndex)
        return regionIndex[]
    end

    # int ncCamStatsRemoveRegion(NcCam cam, int regionIndex);
    # int ncGrabStatsRemoveRegion(NcGrab grab, int regionIndex);
    # int ncStatsRemoveRegion(NcStatsCtx *statsCtx, int regionIndex);

    cf = (:ncCamStatsRemoveRegion,
          :ncGrabStatsRemoveRegion,
          :ncStatsRemoveRegion)[i]

    @eval removeRegion(handle::$T, regionIndex::Integer) =
        @call($cf, Status, ($T, Cint), handle, regionIndex)

    # int ncCamStatsResizeRegion(NcCam cam, int regionIndex,
    #         int regionWidth, int regionHeight);
    # int ncGrabStatsResizeRegion(NcGrab grab, int regionIndex,
    #         int regionWidth, int regionHeight);
    # int ncStatsResizeRegion(NcStatsCtx *statsCtx, int regionIndex,
    #         int regionWidth, int regionHeight);

    cf = (:ncCamStatsResizeRegion,
          :ncGrabStatsResizeRegion,
          :ncStatsResizeRegion)[i]

    @eval function resizeRegion(handle::$T, regionIndex::Integer,
                                regionWidth::Integer, regionHeight::Integer)
        @call($cf, Status, ($T, Cint, Cint, Cint),
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

    cf = (:ncCamStatsGetCrossSection,
          :ncGrabStatsGetCrossSection,
          :ncStatsGetHistoCrossSection)[i]

    @eval function getHistoCrossSection(handle::$T, regionIndex::Integer,
                                        image::Ptr{Image}, xCoord::Integer,
                                        yCoord::Integer)
        stats = Array{Cdouble}(5)
        histo = Ref{Ptr{Cdouble}}()
        crossSectionHorizontal = Ref{Ptr{Cdouble}}()
        crossSectionVertical = Ref{Ptr{Cdouble}}()
        @call($cf, Status,
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

    cf = (:ncCamStatsGetGaussFit,
          :ncGrabStatsGetGaussFit,
          :ncStatsGetGaussFit)[i]

    @eval function getGaussFit(handle::$T, regionIndex::Integer,
                               image::Ptr{Image}, xCoord::Integer,
                               yCoord::Integer, useActualCrossSection::Bool)
        maxAmplitude = Ref{Cdouble}()
        gaussSumHorizontal = Array{Cdouble}(3)
        gaussSumVertical = Array{Cdouble}(3)
        @call($cf, Status, ($T, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble},
                            Ptr{Cdouble}, Ptr{Cdouble}, Cint),
              handle, regionIndex, image, xCoord, yCoord, maxAmplitude,
              gaussSumHorizontal, gaussSumVertical, useActualCrossSection)
        return maxAmplitude[], gaussSumHorizontal, gaussSumVertical
    end

end


#------------------------------------------------------------------------------
# PARAMETERS

getParam(::Type{Bool}, src::Union{Cam,Grab}, name::Name) =
    (getParamInt(src, name) != 0)

getParam(::Type{T}, src::Union{Cam,Grab}, name::Name) where {T<:Integer} =
    convert(T, getParamInt(src, name))

getParam(::Type{T}, src::Union{Cam,Grab}, name::Name) where {T<:AbstractFloat} =
    convert(T, getParamDbl(src, name))

function getParam(::Type{String}, src::Union{Cam,Grab}, name::Name)
    siz = getParamStrSize(src, name)
    buf = Array{Cchar}(siz + 1) # FIXME: check this!
    getParamStr(src, name, buf)
    buf[end] = 0
    return unsafe_string(pointer(buf)) # FIXME: is there a better way?
end

getParam(::Type{Function}, src::Union{Cam,Grab}, name::Name) =
    getParamCallback(src, name)


for (H, jf, cf) in (

    # int ncGrabParamGetCountInt(NcGrab grab, int* count);
    (Grab, :getParamCountInt, :ncGrabParamGetCountInt),

    # int ncCamParamGetCountInt(NcCam cam, int* count);
    (Cam, :getParamCountInt, :ncCamParamGetCountInt),

    # int ncGrabParamGetCountDbl(NcGrab grab, int* count);
    (Grab, :getParamCountDbl, :ncGrabParamGetCountDbl),

    # int ncCamParamGetCountDbl(NcCam cam, int* count);
    (Cam, :getParamCountDbl, :ncCamParamGetCountDbl),

    # int ncGrabParamGetCountStr(NcGrab grab, int* count);
    (Grab, :getParamCountStr, :ncGrabParamGetCountStr),

    # int ncCamParamGetCountStr(NcCam cam, int* count);
    (Cam, :getParamCountStr, :ncCamParamGetCountStr),

    # int ncGrabParamGetCountVoidPtr(NcGrab grab, int* count);
    (Grab, :getParamCountVoidPtr, :ncGrabParamGetCountVoidPtr),

    # int ncCamParamGetCountVoidPtr(NcCam cam, int* count);
    (Cam, :getParamCountVoidPtr, :ncCamParamGetCountVoidPtr),

    # int ncGrabParamGetCountCallback(NcGrab grab, int* count);
    (Grab, :getParamCountCallback, :ncGrabParamGetCountCallback),

    # int ncCamParamGetCountCallback(NcCam cam, int* count);
    (Cam, :getParamCountCallback, :ncCamParamGetCountCallback))

    @eval function $jf(handle::$H)
        value = Ref{Cint}()
        @call($cf, Status, ($H, Ptr{Cint}), handle, value)
        return value[]
    end

end

for (H, jf, cf) in (

    # int ncGrabParamSupportedInt(NcGrab grab, const char* paramName,
    #         int* supported);
    (Grab, :supportedParamInt, :ncGrabParamSupportedInt),

    # int ncCamParamSupportedInt(NcCam cam, const char* paramName,
    #         int* supported);
    (Cam, :supportedParamInt, :ncCamParamSupportedInt),

    # int ncGrabParamSupportedDbl(NcGrab grab, const char* paramName, int* supported);
    (Grab, :supportedParamDbl, :ncGrabParamSupportedDbl),

    # int ncCamParamSupportedDbl(NcCam cam, const char* paramName, int* supported);
    (Cam, :supportedParamDbl, :ncCamParamSupportedDbl),

    # int ncGrabParamSupportedStr(NcGrab grab, const char* paramName, int* supported);
    (Grab, :supportedParamStr, :ncGrabParamSupportedStr),

    # int ncCamParamSupportedStr(NcCam cam, const char* paramName, int* supported);
    (Cam, :supportedParamStr, :ncCamParamSupportedStr),

    # int ncGrabParamSupportedVoidPtr(NcGrab grab, const char* paramName, int* supported);
    (Grab, :supportedParamVoidPtr, :ncGrabParamSupportedVoidPtr),

    # int ncCamParamSupportedVoidPtr(NcCam cam, const char* paramName, int* supported);
    (Cam, :supportedParamVoidPtr, :ncCamParamSupportedVoidPtr),

    # int ncGrabParamSupportedCallback(NcGrab grab, const char* paramName, int* supported);
    (Grab, :supportedParamCallback, :ncGrabParamSupportedCallback),

    # int ncCamParamSupportedCallback(NcCam cam, const char* paramName, int* supported);
    (Cam, :supportedParamCallback, :ncCamParamSupportedCallback))

    @eval function $jf(handle::$H, name::Name)
        flag = Ref{Cint}()
        @call($cf, Status, ($H, Cstring, Ptr{Cint}), handle, name, flag)
        return (flag[] != 0)
    end

end

for (H, jf, cf) in (

    # int ncGrabParamGetNameInt(NcGrab grab, int index, const char** name);
    (Grab, :getParamNameInt, :ncGrabParamGetNameInt),

    # int ncCamParamGetNameInt(NcCam cam, int index, const char** name);
    (Cam, :getParamNameInt, :ncCamParamGetNameInt),

    # int ncGrabParamGetNameDbl(NcGrab grab, int index, const char** name);
    (Grab, :getParamNameDbl, :ncGrabParamGetNameDbl),

    # int ncCamParamGetNameDbl(NcCam cam, int index, const char** name);
    (Cam, :getParamNameDbl, :ncCamParamGetNameDbl),

    # int ncGrabParamGetNameStr(NcGrab grab, int index, const char** name);
    (Grab, :getParamNameStr, :ncGrabParamGetNameStr),

    # int ncCamParamGetNameStr(NcCam cam, int index, const char** name);
    (Cam, :getParamNameStr, :ncCamParamGetNameStr),

    # int ncGrabParamGetNameVoidPtr(NcGrab grab, int index, const char** name);
    (Grab, :getParamNameVoidPtr, :ncGrabParamGetNameVoidPtr),

    # int ncCamParamGetNameVoidPtr(NcCam cam, int index, const char** name);
    (Cam, :getParamNameVoidPtr, :ncCamParamGetNameVoidPtr),

    # int ncGrabParamGetNameCallback(NcGrab grab, int index, const char** name);
    (Grab, :getParamNameCallback, :ncGrabParamGetNameCallback),

    # int ncCamParamGetNameCallback(NcCam cam, int index, const char** name);
    (Cam, :getParamNameCallback, :ncCamParamGetNameCallback))

    @eval function $jf(handle::$H, index::Integer)
        ptr = Ref{Ptr{Cchar}}()
        @call($cf, Status, ($H, Cint, Ptr{Ptr{Cchar}}), handle, index, ptr)
        return unsafe_string(ptr[])
    end

end

for (H, jf, Tj, cf, Tc) in (

    # int ncGrabParamSetInt(NcGrab grab, const char* paramName, int value);
    (Grab, :setParamInt, Integer, :ncGrabParamSetInt, Cint),

    # int ncCamParamSetInt(NcCam cam, const char* paramName, int value);
    (Cam, :setParamInt, Integer, :ncCamParamSetInt, Cint),

    # int ncGrabParamSetDbl(NcGrab grab, const char* paramName, double value);
    (Grab, :setParamDbl, Real, :ncGrabParamSetDbl, Cdouble),

    # int ncCamParamSetDbl(NcCam cam, const char* paramName, double value);
    (Cam, :setParamDbl, Real, :ncCamParamSetDbl, Cdouble),

    # int ncGrabParamSetStr(NcGrab grab, const char* paramName,
    #         const char* value);
    (Grab, :setParamStr, Name, :ncGrabParamSetStr, Cstring),

    # int ncCamParamSetStr(NcCam cam, const char* paramName, const char* value);
    (Cam, :setParamStr, Name, :ncCamParamSetStr, Cstring),

    # int ncGrabParamSetVoidPtr(NcGrab grab, const char* paramName,
    #         void* value);
    (Grab, :setParamVoidPtr, Ptr, :ncGrabParamSetVoidPtr, Ptr{Void}),

    # int ncCamParamSetVoidPtr(NcCam cam, const char* paramName, void* value);
    (Cam, :setParamVoidPtr, Ptr, :ncCamParamSetVoidPtr, Ptr{Void}))

    @eval $jf(handle::$H, name::Name, value::$Tj) =
        @call($cf, Status, ($H, Cstring, $Tc), handle, name, value)

end

for (H, jf, cf) in (

    # int ncGrabParamSetCallback(NcGrab grab, const char* paramName,
    #         void(*callback)(void*), void* data);
    (Grab, :setParamCallback, :ncGrabParamSetCallback),

    # int ncCamParamSetCallback(NcCam cam, const char* paramName,
    #         void(*callback)(void*), void *data);
    (Cam, :setParamCallback, :ncCamParamSetCallback))

    @eval $jf(handle::$H, name::Name, fct::Ptr{Void}, data::Ptr{Void}) =
        @call($cf, Status, ($H, Cstring, Ptr{Void}, Ptr{Void}),
              handle, name, fct, data)
end


for (H, jf, cf) in (

    # int ncGrabParamUnsetInt(NcGrab grab, const char * paramName);
    (Grab, :unsetParamInt, :ncGrabParamUnsetInt),

    # int ncCamParamUnsetInt(NcCam cam, const char * paramName);
    (Cam, :unsetParamInt, :ncCamParamUnsetInt),

    # int ncGrabParamUnsetDbl(NcGrab grab, const char * paramName);
    (Grab, :unsetParamDbl, :ncGrabParamUnsetDbl),

    # int ncCamParamUnsetDbl(NcCam cam, const char * paramName);
    (Cam, :unsetParamDbl, :ncCamParamUnsetDbl),

    # int ncGrabParamUnsetStr(NcGrab grab, const char * paramName);
    (Grab, :unsetParamStr, :ncGrabParamUnsetStr),

    # int ncCamParamUnsetStr(NcCam cam, const char * paramName);
    (Cam, :unsetParamStr, :ncCamParamUnsetStr),

    # int ncGrabParamUnsetVoidPtr(NcGrab grab, const char * paramName);
    (Grab, :unsetParamVoidPtr, :ncGrabParamUnsetVoidPtr),

    # int ncCamParamUnsetVoidPtr(NcCam cam, const char * paramName);
    (Cam, :unsetParamVoidPtr, :ncCamParamUnsetVoidPtr),

    # int ncGrabParamUnsetCallback(NcGrab grab, const char * paramName);
    (Grab, :unsetParamCallback, :ncGrabParamUnsetCallback),

    # int ncCamParamUnsetCallback(NcCam cam, const char * paramName);
    (Cam, :unsetParamCallback, :ncCamParamUnsetCallback))

    @eval $jf(handle::$H, name::Name) =
        @call($cf, Status, ($H, Cstring), handle, name)

end


for (H, jf, cf, T) in (

    # int ncGrabParamGetInt(NcGrab grab, const char* paramName, int* value);
    (Grab, :getParamInt, :ncGrabParamGetInt, Cint),

    # int ncCamParamGetInt(NcCam cam, const char* paramName, int* value);
    (Cam, :getParamInt, :ncCamParamGetInt, Cint),

    # int ncGrabParamGetDbl(NcGrab grab, const char* paramName, double* value);
    (Grab, :getParamDbl, :ncGrabParamGetDbl, Cdouble),

    # int ncCamParamGetDbl(NcCam cam, const char* paramName, double* value);
    (Cam, :getParamDbl, :ncCamParamGetDbl, Cdouble),

    # int ncGrabParamGetStrSize(NcGrab grab, const char* paramName,
    #        int* valueSize);
    (Grab, :getParamStrSize, :ncGrabParamGetStrSize, Cint),

    # int ncCamParamGetStrSize(NcCam cam, const char* paramName,
    #        int* valueSize);
    (Cam, :getParamStrSize, :ncCamParamGetStrSize, Cint),

    # int ncGrabParamGetVoidPtr(NcGrab grab, const char* paramName,
    #        void** value);
    (Grab, :getParamVoidPtr, :ncGrabParamGetVoidPtr, Ptr{Void}),

    # int ncCamParamGetVoidPtr(NcCam cam, const char* paramName,
    #        void** value);
    (Cam, :getParamVoidPtr, :ncCamParamGetVoidPtr, Ptr{Void}))

    @eval function $jf(handle::$H, name::Name)
        value = ref{$T}()
        @call($cf, Status, ($H, Cstring, Ptr{$T}), handle, name, value)
        return value[]
    end

end

for (H, cf) in (

    # int ncGrabParamGetStr(NcGrab grab, const char* paramName,
    #         char* outBuffer, int bufferSize);
    (Grab, :ncGrabParamGetStr),

    # int ncCamParamGetStr(NcCam cam, const char* paramName,
    #         char* outBuffer, int bufferSize);
    (Cam, :ncCamParamGetStr))

    @eval getParamStr(handle::$H, name::Name, buf::Array{Cchar}) =
        @call($cf, Status, ($H, Cstring, Ptr{Cchar}, Cint),
              handle, name, buf, sizeof(buf))

end

for (H, cf) in (

    # int ncGrabParamGetCallback(NcGrab grab, const char* paramName,
    #         void(**callback)(void*), void** data);
    (Grab, :ncGrabParamGetCallback),

    # int ncCamParamGetCallback(NcCam cam, const char* paramName,
    #         void(**callback)(void*), void** data);
    (Cam, :ncCamParamGetCallback))

    @eval function getParamCallback(handle::$H, name::Name)
        fct = Ref{Ptr{Void}}()
        data = Ref{Ptr{Void}}()
        @call($cf, Status, ($H, Cstring, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}),
              handle, name, fct, data)
        return fct[], data[]
    end

end
