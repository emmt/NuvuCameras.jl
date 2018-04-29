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
# 233 have been currently interfaced.
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

#- # int ncWriteFileHeader(NcImageSaved *currentFile, enum HeaderDataType dataType, const char *name, const void *value, const char *comment);
#- @inline ncWriteFileHeader(currentFile::ImageSaved, dataType::HeaderDataType, name::Ptr{Cchar}, value::Ptr{Void}, comment::Ptr{Cchar}) =
#-     @call(:ncWriteFileHeader, Status,
#-           (ImageSaved, HeaderDataType, Ptr{Cchar}, Ptr{Void}, Ptr{Cchar}),
#-           currentFile, dataType, name, value, comment)

#- # int ncReadFileHeader(NcImageSaved *currentFile, enum HeaderDataType dataType, const char *name, const void *value);
#- @inline ncReadFileHeader(currentFile::ImageSaved, dataType::HeaderDataType, name::Ptr{Cchar}, value::Ptr{Void}) =
#-     @call(:ncReadFileHeader, Status,
#-           (ImageSaved, HeaderDataType, Ptr{Cchar}, Ptr{Void}),
#-           currentFile, dataType, name, value)

#- # int ncImageGetFileFormat(NcImageSaved *image, enum ImageFormat * format);
#- @inline ncImageGetFileFormat(image::ImageSaved, format::Ptr{ImageFormat}) =
#-     @call(:ncImageGetFileFormat, Status,
#-           (ImageSaved, Ptr{ImageFormat}),
#-           image, format)

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

    @eval begin

        function $cf(ctrlList::CtrlList)
            value = Ref{$T}()
            @call($cf, Status, (CtrlList, Ptr{$T}), ctrlList, value)
            return value[]
        end

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

    @eval begin

        function $cf(ctrlList::CtrlList, index::Integer)
            value = Ref{$T}()
            @call($cf, Status, (CtrlList, Cint, Ptr{$T}),
                  ctrlList, index, value)
            return value[]
        end

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
    @eval begin

        function $jf(ctrlList::CtrlList, index::Integer)
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
end

for (jf, cf, T1, T2) in (

    # int ncControllerListGetFullSizeSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
    (:getFullSizeSize, :ncControllerListGetFullSizeSize, Cint, Cint),

    # int ncControllerListGetDetectorSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
    (:getDetectorSize, :ncControllerListGetDetectorSize, Cint, Cint))

    @eval begin

        function $cf(ctrlList::CtrlList, index::Integer)
            val1 = Ref{$T1}()
            val2 = Ref{$T2}()
            @call($cf, Status, (CtrlList, Cint, Ptr{$T1}, Ptr{$T2}),
                  ctrlList, index, val1, val2)
            return val1[], val2[]
        end

    end
end


#------------------------------------------------------------------------------
# GRAB FUNCTIONS

@inline setOpenMacAddress(::Type{Grab}, macAddress::Name) =
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

    @eval begin

        @inline $jf(grab::Grab) =
            @call($cf, Status, (Grab, ), grab)

    end

end

for (jf, Tj, cf, Tc) in (

    # int ncGrabStart(NcGrab grab, int nbrImages);
    (:start, Integer, :ncGrabStart, Cint),

    # int ncGrabSetHeartbeat(NcGrab grab, int timeMs);
    (:setHeartbeat, Integer, :ncGrabSetHeartbeat, Cint),

    # int ncGrabSetTimeout(NcGrab grab, int timeMs);
    (:setTimeout, Integer, :ncGrabSetTimeout, Cint),

    # int ncGrabSetTimestampMode(NcGrab grab, enum TimestampMode timestampMode);
    (:setTimeout, TimestampMode, :ncGrabSetTimeout, TimestampMode),

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
    (:createBias, Integer, :ncGrabCreateBias, Cint),

    # int ncGrabStatsRemoveRegion(NcGrab grab, int regionIndex);
    (:removeRegion, Integer, :ncGrabStatsRemoveRegion, Cint))

    @eval begin

        @inline $jf(grab::Grab, value::$Tj) =
            @call($cf, Status, (Grab, $Tc), grab, value)

    end
end

#- # int ncGrabRead(NcGrab grab, NcImage** imageAcqu);
#- @inline ncGrabRead(grab::Grab, imageAcqu::Ptr{Ptr{Image}}) =
#-     @call(:ncGrabRead, Status,
#-           (Grab, Ptr{Ptr{Image}}),
#-           grab, imageAcqu)

#- # int ncGrabReadChronological(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
#- @inline ncGrabReadChronological(grab::Grab, imageAcqu::Ptr{Ptr{Image}}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncGrabReadChronological, Status,
#-           (Grab, Ptr{Ptr{Image}}, Ptr{Cint}),
#-           grab, imageAcqu, nbrImagesSkipped)

#- # int ncGrabReadChronologicalNonBlocking(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
#- @inline ncGrabReadChronologicalNonBlocking(grab::Grab, imageAcqu::Ptr{Ptr{Image}}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncGrabReadChronologicalNonBlocking, Status,
#-           (Grab, Ptr{Ptr{Image}}, Ptr{Cint}),
#-           grab, imageAcqu, nbrImagesSkipped)

@inline function open(::Type{ImageParams{Grab}})
    value = Ref{ImageParams{Grab}}()
    # int ncGrabOpenImageParams(ImageParams *imageParams);
    @call(:ncGrabOpenImageParams, Status, (Ptr{ImageParams}, ), value)
    return value[]
end

#- # int ncGrabGetImageParams(NcGrab grab, void* imageNc, ImageParams imageParams);
#- @inline ncGrabGetImageParams(grab::Grab, imageNc::Ptr{Void}, imageParams::ImageParams) =
#-     @call(:ncGrabGetImageParams, Status,
#-           (Grab, Ptr{Void}, ImageParams),
#-           grab, imageNc, imageParams)

@inline close(imageParams::ImageParams{Grab}) =
    # int ncGrabCloseImageParams(ImageParams imageParams);
    @call(:ncGrabCloseImageParams, Status, (ImageParams, ), imageParams)

for (jf, cf, T) in (
    # int ncGrabGetOverrun(NcGrab grab, int* overrunOccurred);
    (:getOverrun, :ncGrabGetOverrun, Cint),

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

    @eval begin

        @inline function $jf(grab::Grab)
            value = Ref{$T}()
            @call($cf, Status, (Grab, Ptr{$T}), grab, value)
            return value[]
        end

    end
end

@inline setSize(grab::Grab, width::Integer, height::Integer) =
    # int ncGrabSetSize(NcGrab grab, int width, int height);
    @call(:ncGrabSetSize, Status, (Grab, Cint, Cint), grab, width, height)

@inline function getSize(grab::Grab)
    width = Ref{Cint}()
    height = Ref{Cint}()
    # int ncGrabGetSize(NcGrab grab, int* width, int* height);
    @call(:ncGrabGetSize, Status, (Grab, Ptr{Cint}, Ptr{Cint}),
          grab, width, height)
    return width[], height[]
end

#- # int ncGrabSaveImage(NcGrab grab, const NcImage* imageNc, const char* saveName, enum ImageFormat saveFormat, int overwriteFlag);
#- @inline ncGrabSaveImage(grab::Grab, imageNc::Ptr{Image}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, overwriteFlag::Cint) =
#-     @call(:ncGrabSaveImage, Status,
#-           (Grab, Ptr{Image}, Ptr{Cchar}, ImageFormat, Cint),
#-           grab, imageNc, saveName, saveFormat, overwriteFlag)

#- # int ncGrabSaveImageEx(NcGrab grab, const void* imageNc, const char* saveName, enum ImageFormat saveFormat, enum ImageDataType dataFormat, int overwriteFlag);
#- @inline ncGrabSaveImageEx(grab::Grab, imageNc::Ptr{Void}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, dataFormat::ImageDataType, overwriteFlag::Cint) =
#-     @call(:ncGrabSaveImageEx, Status,
#-           (Grab, Ptr{Void}, Ptr{Cchar}, ImageFormat, ImageDataType, Cint),
#-           grab, imageNc, saveName, saveFormat, dataFormat, overwriteFlag)

#- # int ncGrabStartSaveAcquisition(NcGrab grab, const char *saveName, enum ImageFormat saveFormat, int imagesPerCubes, int nbrOfCubes, int overwriteFlag);
#- @inline ncGrabStartSaveAcquisition(grab::Grab, saveName::Ptr{Cchar}, saveFormat::ImageFormat, imagesPerCubes::Cint, nbrOfCubes::Cint, overwriteFlag::Cint) =
#-     @call(:ncGrabStartSaveAcquisition, Status,
#-           (Grab, Ptr{Cchar}, ImageFormat, Cint, Cint, Cint),
#-           grab, saveName, saveFormat, imagesPerCubes, nbrOfCubes, overwriteFlag)


#- # int ncGrabSaveImageSetHeaderCallback(NcGrab grab, void (*fct)(NcGrab grab, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncGrabSaveImageSetHeaderCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabSaveImageSetHeaderCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

#- # int ncGrabSaveImageWriteCallback(NcGrab grab, void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
#- @inline ncGrabSaveImageWriteCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabSaveImageWriteCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

#- # int ncGrabSaveImageCloseCallback(NcGrab grab, void (*fct)(NcGrab grab, int fileNo, void *data), void *data);
#- @inline ncGrabSaveImageCloseCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabSaveImageCloseCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

@inline ncGrabSaveParam(grab::Grab, name::Name, overwrite::Bool) =
    # int ncGrabSaveParam(NcGrab grab, const char *saveName, int overwriteFlag);
    @call(:ncGrabSaveParam, Status, (Grab, Cstring, Cint),
          grab, name, overwrite)

#- # int ncGrabSaveParamSetHeaderCallback(NcGrab grab, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncGrabSaveParamSetHeaderCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabSaveParamSetHeaderCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

#- # int ncGrabLoadParamSetHeaderCallback(NcGrab grab, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncGrabLoadParamSetHeaderCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabLoadParamSetHeaderCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

#- # int ncGrabGetTimestampMode(NcGrab grab, int ctrlRequest, enum TimestampMode *timestampMode, int *gpsSignalValid);
#- @inline ncGrabGetTimestampMode(grab::Grab, ctrlRequest::Cint, timestampMode::Ptr{TimestampMode}, gpsSignalValid::Ptr{Cint}) =
#-     @call(:ncGrabGetTimestampMode, Status,
#-           (Grab, Cint, Ptr{TimestampMode}, Ptr{Cint}),
#-           grab, ctrlRequest, timestampMode, gpsSignalValid)

#- # int ncGrabSetTimestampInternal(NcGrab grab, struct tm *dateTime, int nbrUs);
#- @inline ncGrabSetTimestampInternal(grab::Grab, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
#-     @call(:ncGrabSetTimestampInternal, Status,
#-           (Grab, Ptr{TmStruct}, Cint),
#-           grab, dateTime, nbrUs)

#- # int ncGrabGetCtrlTimestamp(NcGrab grab, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
#- @inline ncGrabGetCtrlTimestamp(grab::Grab, imageAcqu::Ptr{Image}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
#-     @call(:ncGrabGetCtrlTimestamp, Status,
#-           (Grab, Ptr{Image}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
#-           grab, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

#- # int ncGrabGetHostSystemTimestamp(NcGrab grab, NcImage* imageAcqu, double *hostSystemTimestamp);
#- @inline ncGrabGetHostSystemTimestamp(grab::Grab, imageAcqu::Ptr{Image}, hostSystemTimestamp::Ptr{Cdouble}) =
#-     @call(:ncGrabGetHostSystemTimestamp, Status,
#-           (Grab, Ptr{Image}, Ptr{Cdouble}),
#-           grab, imageAcqu, hostSystemTimestamp)

#- # int ncGrabParamAvailable(NcGrab grab, enum Features param, int setting);
#- @inline ncGrabParamAvailable(grab::Grab, param::Features, setting::Cint) =
#-     @call(:ncGrabParamAvailable, Status,
#-           (Grab, Features, Cint),
#-           grab, param, setting)

@inline setEvent(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
    # int ncGrabSetEvent(NcGrab grab, NcCallbackFunc funcName, void* ncData);
    @call(:ncGrabSetEvent, Status, (Grab, Ptr{Void}, Ptr{Void}),
          grab, fct, data)

#- # int ncGrabSendSerialBinaryComm(NcGrab grab, const char *command, int length);
#- @inline ncGrabSendSerialBinaryComm(grab::Grab, command::Ptr{Cchar}, length::Cint) =
#-     @call(:ncGrabSendSerialBinaryComm, Status,
#-           (Grab, Ptr{Cchar}, Cint),
#-           grab, command, length)

#- # int ncGrabWaitSerialCmd(NcGrab grab, int length, int* numByte);
#- @inline ncGrabWaitSerialCmd(grab::Grab, length::Cint, numByte::Ptr{Cint}) =
#-     @call(:ncGrabWaitSerialCmd, Status,
#-           (Grab, Cint, Ptr{Cint}),
#-           grab, length, numByte)

#- # int ncGrabRecSerial(NcGrab grab, char *recBuffer, int length, int* numByte);
#- @inline ncGrabRecSerial(grab::Grab, recBuffer::Ptr{Cchar}, length::Cint, numByte::Ptr{Cint}) =
#-     @call(:ncGrabRecSerial, Status,
#-           (Grab, Ptr{Cchar}, Cint, Ptr{Cint}),
#-           grab, recBuffer, length, numByte)


#- # int ncGrabGetVersion(NcGrab grab, enum VersionType versionType, char * version, int bufferSize);
#- @inline ncGrabGetVersion(grab::Grab, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
#-     @call(:ncGrabGetVersion, Status,
#-           (Grab, VersionType, Ptr{Cchar}, Cint),
#-           grab, versionType, version, bufferSize)

#- # int ncGrabSetProcType(NcGrab grab, int type, int nbrImagesPc);
#- @inline ncGrabSetProcType(grab::Grab, _type::Cint, nbrImagesPc::Cint) =
#-     @call(:ncGrabSetProcType, Status,
#-           (Grab, Cint, Cint),
#-           grab, _type, nbrImagesPc)

#- # int ncGrabGetProcType(NcGrab grab, int * type, int * nbrImagesPc);
#- @inline ncGrabGetProcType(grab::Grab, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
#-     @call(:ncGrabGetProcType, Status,
#-           (Grab, Ptr{Cint}, Ptr{Cint}),
#-           grab, _type, nbrImagesPc)

#- # int ncGrabCreateBiasNewImageCallback(NcGrab grab, void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
#- @inline ncGrabCreateBiasNewImageCallback(grab::Grab, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncGrabCreateBiasNewImageCallback, Status,
#-           (Grab, Ptr{Void}, Ptr{Void}),
#-           grab, fct, data)

#- # int ncGrabStatsAddRegion(NcGrab grab, int regionWidth, int regionHeight, int *regionIndex);
#- @inline ncGrabStatsAddRegion(grab::Grab, regionWidth::Cint, regionHeight::Cint, regionIndex::Ptr{Cint}) =
#-     @call(:ncGrabStatsAddRegion, Status,
#-           (Grab, Cint, Cint, Ptr{Cint}),
#-           grab, regionWidth, regionHeight, regionIndex)

#- # int ncGrabStatsResizeRegion(NcGrab grab, int regionIndex, int regionWidth, int regionHeight);
#- @inline ncGrabStatsResizeRegion(grab::Grab, regionIndex::Cint, regionWidth::Cint, regionHeight::Cint) =
#-     @call(:ncGrabStatsResizeRegion, Status,
#-           (Grab, Cint, Cint, Cint),
#-           grab, regionIndex, regionWidth, regionHeight)

#- # int ncGrabStatsGetCrossSection(NcGrab grab, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
#- @inline ncGrabStatsGetCrossSection(grab::Grab, regionIndex::Cint, image::Ptr{Image}, xCoord::Cint, yCoord::Cint, statsCtxRegion::Ptr{Cdouble}, histo::Ptr{Ptr{Cdouble}}, crossSectionHorizontal::Ptr{Ptr{Cdouble}}, crossSectionVertical::Ptr{Ptr{Cdouble}}) =
#-     @call(:ncGrabStatsGetCrossSection, Status,
#-           (Grab, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
#-           grab, regionIndex, image, xCoord, yCoord, statsCtxRegion, histo, crossSectionHorizontal, crossSectionVertical)

#- # int ncGrabStatsGetGaussFit(NcGrab grab, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSection);
#- @inline ncGrabStatsGetGaussFit(grab::Grab, regionIndex::Cint, image::Ptr{Image}, xCoord::Cint, yCoord::Cint, maxAmplitude::Ptr{Cdouble}, gaussSumHorizontal::Ptr{Cdouble}, gaussSumVertical::Ptr{Cdouble}, useActualCrossSection::Cint) =
#-     @call(:ncGrabStatsGetGaussFit, Status,
#-           (Grab, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
#-           grab, regionIndex, image, xCoord, yCoord, maxAmplitude, gaussSumHorizontal, gaussSumVertical, useActualCrossSection)

#------------------------------------------------------------------------------
# CAMERA FUNCTIONS

@inline setOpenMacAddress(::Type{Cam}, macAddress::Name) =
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

    @eval begin

        @inline $jf(cam::Cam) =
            @call($cf, Status, (Cam, ), cam)

    end

end

@inline readyToClose(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
    # int ncCamReadyToClose(NcCam cam, void (*fct)(NcCam cam, void *data), void *data);
    @call(:ncCamReadyToClose, Status, (Cam, Ptr{Void}, Ptr{Void}),
          cam, fct, data)

for (jf, Tj, cf, Tc) in (

    # int ncCamStart(NcCam cam, int nbrImages);
    (:start, Integer, :ncCamStart, Cint),

    # int ncCamPrepareAcquisition(NcCam cam, int nbrImages);
    (:prepareAcquisition, Integer, :ncCamPrepareAcquisition, Cint),

    # int ncCamSetHeartbeat(NcCam cam, int timeMs);
    (:setHeartbeat, Integer, :ncCamSetHeartbeat, Cint),

    # int ncCamSetTimeout(NcCam cam, int timeMs);
    (:setTimeout, Integer, :ncCamSetTimeout, Cint),

    # int ncCamSetTimestampMode(NcCam cam, enum TimestampMode timestampMode);
    (:setTimeout, TimestampMode, :ncCamSetTimeout, TimestampMode),

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

    # int ncCamSetExternalShutter(NcCam cam, enum ExtShutter externalShutterPresence);
    (:setExternalShutter, ExtShutter, :ncCamSetExternalShutter, ExtShutter),

    # int ncCamSetExternalShutterMode(NcCam cam, enum ShutterMode externalShutterMode);
    (:setExternalShutterMode, ShutterMode, :ncCamSetExternalShutterMode, ShutterMode),

    # int ncCamSetExternalShutterDelay(NcCam cam, double externalShutterDelay);
    (:setExternalShutterDelay, Real, :ncCamSetExternalShutterDelay, Cdouble),

    # int ncCamSetFirePolarity(NcCam cam, enum ExtPolarity firePolarity);
    (:setFirePolarity, ExtPolarity, :ncCamSetFirePolarity, ExtPolarity),

    # int ncCamSetOutputMinimumPulseWidth(NcCam cam, double outputPulseWidth);
    (:setOutputMinimumPulseWidth, Real, :ncCamSetOutputMinimumPulseWidth, Cdouble),

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

    @eval begin

        @inline $jf(cam::Cam, value::$Tj) =
            @call($cf, Status, (Cam, $Tc), cam, value)

    end
end

"""
```julia
getHeartbeat(cam) -> ms
```
""" getHeartbeat



#- # int ncSaveImage(int width, int height, ImageParams imageParams, const void* imageNc, enum ImageDataType dataType, const char* saveName, enum ImageFormat saveFormat, enum ImageCompression compress, const char* addComments, int overwriteFlag);
#- @inline ncSaveImage(width::Cint, height::Cint, imageParams::ImageParams, imageNc::Ptr{Void}, dataType::ImageDataType, saveName::Ptr{Cchar}, saveFormat::ImageFormat, compress::ImageCompression, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncSaveImage, Status,
#-           (Cint, Cint, ImageParams, Ptr{Void}, ImageDataType, Ptr{Cchar}, ImageFormat, ImageCompression, Ptr{Cchar}, Cint),
#-           width, height, imageParams, imageNc, dataType, saveName, saveFormat, compress, addComments, overwriteFlag)

@inline function open(::Type{ImageParams{Cam}})
    value = Ref{ImageParams{Cam}}()
    # int ncCamOpenImageParams(ImageParams *imageParams);
    @call(:ncCamOpenImageParams, Status, (Ptr{ImageParams}, ), value)
    return value[]
end

#- # int ncCamGetImageParams(NcCam cam, void* imageNc, ImageParams imageParams);
#- @inline ncCamGetImageParams(cam::Cam, imageNc::Ptr{Void}, imageParams::ImageParams) =
#-     @call(:ncCamGetImageParams, Status,
#-           (Cam, Ptr{Void}, ImageParams),
#-           cam, imageNc, imageParams)

@inline close(imageParams::ImageParams{Cam}) =
    # int ncCamCloseImageParams(ImageParams imageParams);
    @call(:ncCamCloseImageParams, Status, (ImageParams, ), imageParams)

#- # int ncCamRead(NcCam cam, NcImage** imageAcqu);
#- @inline ncCamRead(cam::Cam, imageAcqu::Ptr{Ptr{Image}}) =
#-     @call(:ncCamRead, Status,
#-           (Cam, Ptr{Ptr{Image}}),
#-           cam, imageAcqu)

#- # int ncCamReadUInt32(NcCam cam, uint32_t *image);
#- @inline ncCamReadUInt32(cam::Cam, image::Ptr{UInt32}) =
#-     @call(:ncCamReadUInt32, Status,
#-           (Cam, Ptr{UInt32}),
#-           cam, image)

#- # int ncCamReadFloat(NcCam cam, float *image);
#- @inline ncCamReadFloat(cam::Cam, image::Ptr{Cfloat}) =
#-     @call(:ncCamReadFloat, Status,
#-           (Cam, Ptr{Cfloat}),
#-           cam, image)

#- # int ncCamReadChronological(NcCam cam, NcImage** imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadChronological(cam::Cam, imageAcqu::Ptr{Ptr{Image}}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadChronological, Status,
#-           (Cam, Ptr{Ptr{Image}}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamReadUInt32Chronological(NcCam cam, uint32_t* imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadUInt32Chronological(cam::Cam, imageAcqu::Ptr{UInt32}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadUInt32Chronological, Status,
#-           (Cam, Ptr{UInt32}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamReadFloatChronological(NcCam cam, float* imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadFloatChronological(cam::Cam, imageAcqu::Ptr{Cfloat}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadFloatChronological, Status,
#-           (Cam, Ptr{Cfloat}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamReadChronologicalNonBlocking(NcCam cam, NcImage **imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadChronologicalNonBlocking(cam::Cam, imageAcqu::Ptr{Ptr{Image}}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadChronologicalNonBlocking, Status,
#-           (Cam, Ptr{Ptr{Image}}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamReadUInt32ChronologicalNonBlocking(NcCam cam, uint32_t* imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadUInt32ChronologicalNonBlocking(cam::Cam, imageAcqu::Ptr{UInt32}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadUInt32ChronologicalNonBlocking, Status,
#-           (Cam, Ptr{UInt32}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamReadFloatChronologicalNonBlocking(NcCam cam, float* imageAcqu, int* nbrImagesSkipped);
#- @inline ncCamReadFloatChronologicalNonBlocking(cam::Cam, imageAcqu::Ptr{Cfloat}, nbrImagesSkipped::Ptr{Cint}) =
#-     @call(:ncCamReadFloatChronologicalNonBlocking, Status,
#-           (Cam, Ptr{Cfloat}, Ptr{Cint}),
#-           cam, imageAcqu, nbrImagesSkipped)

#- # int ncCamAllocUInt32Image(NcCam cam, uint32_t **image);
#- @inline ncCamAllocUInt32Image(cam::Cam, image::Ptr{Ptr{UInt32}}) =
#-     @call(:ncCamAllocUInt32Image, Status,
#-           (Cam, Ptr{Ptr{UInt32}}),
#-           cam, image)

#- # int ncCamFreeUInt32Image(uint32_t **image);
#- @inline ncCamFreeUInt32Image(image::Ptr{Ptr{UInt32}}) =
#-     @call(:ncCamFreeUInt32Image, Status,
#-           (Ptr{Ptr{UInt32}}, ),
#-           image)

"""
```julia
getOverrun(cam) -> ovr
```
""" getOverrun

for (jf, cf, T) in (
    # int ncCamGetHeartbeat(NcCam cam, int *timeMs);
    (:getHeartbeat, :ncCamGetHeartbeat, Cint),

    # int ncCamGetOverrun(NcCam cam, int* overrunOccurred);
    (:getOverrun, :ncCamGetOverrun, Cint),

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

    @eval begin

        @inline function $jf(cam::Cam)
            value = Ref{$T}()
            @call($cf, Status, (Cam, Ptr{$T}), cam, value)
            return value[]
        end

    end
end

for (jf, cf, T1, T2) in (
    # int ncCamGetSize(NcCam cam, int *width, int *height);
    (:getSize, :ncCamGetSize, Cint, Cint),

    # int ncCamGetMaxSize(NcCam cam, int *width, int *height);
    (:getMaxSize, :ncCamGetMaxSize, Cint, Cint),

    # int ncCamGetCalibratedEmGainRange(NcCam cam, int* calibratedEmGainMin, int* calibratedEmGainMax);
    (:getCalibratedEmGainRange, :ncCamGetCalibratedEmGainRange, Cint, Cint),

    # int ncCamGetCalibratedEmGainTempRange(NcCam cam, double* calibratedEmGainTempMin, double* calibratedEmGainTempMax);
    (:getCalibratedEmGainTempRange, :ncCamGetCalibratedEmGainTempRange, Cdouble, Cdouble),

    # int ncCamGetRawEmGainRange(NcCam cam, int* rawEmGainMin, int* rawEmGainMax);
    (:getRawEmGainRange, :ncCamGetRawEmGainRange, Cint, Cint),

    # int ncCamGetAnalogGainRange(NcCam cam, int* analogGainMin, int* analogGainMax);
    (:getAnalogGainRange, :ncCamGetAnalogGainRange, Cint, Cint),

    # int ncCamGetAnalogOffsetRange(NcCam cam, int* analogOffsetMin, int* analogOffsetMax);
    (:getAnalogOffsetRange, :ncCamGetAnalogOffsetRange, Cint, Cint),

    # int ncCamGetTargetDetectorTempRange(NcCam cam, double *targetDetectorTempMin, double *targetDetectorTempMax);
    (:getTargetDetectorTempRange, :ncCamGetTargetDetectorTempRange, Cdouble, Cdouble),

    # int ncCamGetBinningMode(NcCam cam, int *binXValue, int *binYValue);
    (:getBinningMode, :ncCamGetBinningMode, Cint, Cint),

    # int ncCamGetActiveRegion(NcCam cam, int *width, int *height);
    (:getActiveRegion, :ncCamGetActiveRegion, Cint, Cint),

    # int ncCamGetFullCCDSize(NcCam cam, int *width, int *height);
    (:getFullCCDSize, :ncCamGetFullCCDSize, Cint, Cint))

    @eval begin

        @inline function $jf(cam::Cam)
            val1 = Ref{$T1}()
            val2 = Ref{$T2}()
            @call($cf, Status, (Cam, Ptr{$T1}, Ptr{$T2}), cam, va1, val2)
            return val1[], val2[]
        end

    end
end

#- # int ncCamSaveImage(NcCam cam, const NcImage* imageNc, const char* saveName, enum ImageFormat saveFormat, const char* addComments, int overwriteFlag);
#- @inline ncCamSaveImage(cam::Cam, imageNc::Ptr{Image}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveImage, Status,
#-           (Cam, Ptr{Image}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
#-           cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

#- # int ncCamSaveUInt32Image(NcCam cam, const uint32_t *imageNc, const char *saveName, enum ImageFormat saveFormat, const char *addComments, int overwriteFlag);
#- @inline ncCamSaveUInt32Image(cam::Cam, imageNc::Ptr{UInt32}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveUInt32Image, Status,
#-           (Cam, Ptr{UInt32}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
#-           cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

#- # int ncCamSaveFloatImage(NcCam cam, const float *imageNc, const char *saveName, enum ImageFormat saveFormat, const char *addComments, int overwriteFlag);
#- @inline ncCamSaveFloatImage(cam::Cam, imageNc::Ptr{Cfloat}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveFloatImage, Status,
#-           (Cam, Ptr{Cfloat}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
#-           cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

#- # int ncCamSaveImageEx(NcCam cam, const void * imageNc, const char* saveName, enum ImageFormat saveFormat, enum ImageDataType dataFormat, const char* addComments, int overwriteFlag);
#- @inline ncCamSaveImageEx(cam::Cam, imageNc::Ptr{Void}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, dataFormat::ImageDataType, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveImageEx, Status,
#-           (Cam, Ptr{Void}, Ptr{Cchar}, ImageFormat, ImageDataType, Ptr{Cchar}, Cint),
#-           cam, imageNc, saveName, saveFormat, dataFormat, addComments, overwriteFlag)

#- # int ncCamStartSaveAcquisition(NcCam cam, const char *saveName, enum ImageFormat saveFormat, int imagesPerCubes, const char *addComments, int nbrOfCubes, int overwriteFlag);
#- @inline ncCamStartSaveAcquisition(cam::Cam, saveName::Ptr{Cchar}, saveFormat::ImageFormat, imagesPerCubes::Cint, addComments::Ptr{Cchar}, nbrOfCubes::Cint, overwriteFlag::Cint) =
#-     @call(:ncCamStartSaveAcquisition, Status,
#-           (Cam, Ptr{Cchar}, ImageFormat, Cint, Ptr{Cchar}, Cint, Cint),
#-           cam, saveName, saveFormat, imagesPerCubes, addComments, nbrOfCubes, overwriteFlag)


#- # int ncCamSaveImageSetHeaderCallback(NcCam cam, void (*fct)(NcCam cam, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncCamSaveImageSetHeaderCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSaveImageSetHeaderCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamSaveImageWriteCallback(NcCam cam, void (*fct)(NcCam cam, int imageNo, void *data), void *data);
#- @inline ncCamSaveImageWriteCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSaveImageWriteCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamSaveImageCloseCallback(NcCam cam, void (*fct)(NcCam cam, int fileNo, void *data), void *data);
#- @inline ncCamSaveImageCloseCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSaveImageCloseCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamSaveImageSetCompressionType(NcCam cam, enum ImageCompression compress);
#- @inline ncCamSaveImageSetCompressionType(cam::Cam, compress::ImageCompression) =
#-     @call(:ncCamSaveImageSetCompressionType, Status,
#-           (Cam, ImageCompression),
#-           cam, compress)

#- # int ncCamSaveImageGetCompressionType(NcCam cam, enum ImageCompression *compress);
#- @inline ncCamSaveImageGetCompressionType(cam::Cam, compress::Ptr{ImageCompression}) =
#-     @call(:ncCamSaveImageGetCompressionType, Status,
#-           (Cam, Ptr{ImageCompression}),
#-           cam, compress)

@inline resetTimer(cam::Cam, timeOffset::Real) =
    # int ncCamResetTimer(NcCam cam, double timeOffset);
    @call(:ncCamResetTimer, Status, (Cam, Cdouble), cam, timeOffset)


@inline setEvent(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
# int ncCamSetEvent(NcCam cam, NcCallbackFunc funcName, void *ncData);
    @call(:ncCamSetEvent, Status, (Cam, Ptr{Void}, Ptr{Void}),
          cam, fct, data)


@inline function getTimestampMode(cam::Cam, cameraRequest::Bool)
    timestampMode = Ref{TimestampMode}()
    gpsSignalValid = Ref{Cint}()
    # int ncCamGetTimestampMode(NcCam cam, int cameraRequest,
    #                           enum TimestampMode *timestampMode,
    #                           int *gpsSignalValid);
    @call(:ncCamGetTimestampMode, Status,
          (Cam, Cint, Ptr{TimestampMode}, Ptr{Cint}),
          cam, cameraRequest, timestampMode, gpsSignalValid)
    return timestampMode[], (gpsSignalValid[] != 0)
end

#- # int ncCamSetTimestampInternal(NcCam cam, struct tm *dateTime, int nbrUs);
#- @inline ncCamSetTimestampInternal(cam::Cam, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
#-     @call(:ncCamSetTimestampInternal, Status,
#-           (Cam, Ptr{TmStruct}, Cint),
#-           cam, dateTime, nbrUs)

#- # int ncCamGetCtrlTimestamp(NcCam cam, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
#- @inline ncCamGetCtrlTimestamp(cam::Cam, imageAcqu::Ptr{Image}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
#-     @call(:ncCamGetCtrlTimestamp, Status,
#-           (Cam, Ptr{Image}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
#-           cam, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

#- # int ncCamGetHostSystemTimestamp(NcCam cam, NcImage* imageAcqu, double *hostSystemTimestamp);
#- @inline ncCamGetHostSystemTimestamp(cam::Cam, imageAcqu::Ptr{Image}, hostSystemTimestamp::Ptr{Cdouble}) =
#-     @call(:ncCamGetHostSystemTimestamp, Status,
#-           (Cam, Ptr{Image}, Ptr{Cdouble}),
#-           cam, imageAcqu, hostSystemTimestamp)

#- # int ncCamParamAvailable(NcCam cam, enum Features param, int setting);
#- @inline ncCamParamAvailable(cam::Cam, param::Features, setting::Cint) =
#-     @call(:ncCamParamAvailable, Status,
#-           (Cam, Features, Cint),
#-           cam, param, setting)

#- # int ncCamSaveParam(NcCam cam, const char* saveName, int overwriteFlag);
#- @inline ncCamSaveParam(cam::Cam, saveName::Ptr{Cchar}, overwriteFlag::Cint) =
#-     @call(:ncCamSaveParam, Status,
#-           (Cam, Ptr{Cchar}, Cint),
#-           cam, saveName, overwriteFlag)

#- # int ncCamSaveParamSetHeaderCallback(NcCam cam, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncCamSaveParamSetHeaderCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSaveParamSetHeaderCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamLoadParamSetHeaderCallback(NcCam cam, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
#- @inline ncCamLoadParamSetHeaderCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamLoadParamSetHeaderCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamGetCurrentReadoutMode(NcCam cam, int* readoutMode, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
#- @inline ncCamGetCurrentReadoutMode(cam::Cam, readoutMode::Ptr{Cint}, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
#-     @call(:ncCamGetCurrentReadoutMode, Status,
#-           (Cam, Ptr{Cint}, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
#-           cam, readoutMode, ampliType, ampliString, vertFreq, horizFreq)

#- # int ncCamGetReadoutMode(NcCam cam, int number, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
#- @inline ncCamGetReadoutMode(cam::Cam, number::Cint, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
#-     @call(:ncCamGetReadoutMode, Status,
#-           (Cam, Cint, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
#-           cam, number, ampliType, ampliString, vertFreq, horizFreq)

#- # int ncCamGetAmpliTypeAvail(NcCam cam, enum Ampli ampli, int *number);
#- @inline ncCamGetAmpliTypeAvail(cam::Cam, ampli::Ampli, number::Ptr{Cint}) =
#-     @call(:ncCamGetAmpliTypeAvail, Status,
#-           (Cam, Ampli, Ptr{Cint}),
#-           cam, ampli, number)

#- # int ncCamGetFreqAvail(NcCam cam, enum Ampli ampli, int ampliNo, int *vertFreq, int *horizFreq, int* readoutModeNo);
#- @inline ncCamGetFreqAvail(cam::Cam, ampli::Ampli, ampliNo::Cint, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}, readoutModeNo::Ptr{Cint}) =
#-     @call(:ncCamGetFreqAvail, Status,
#-           (Cam, Ampli, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
#-           cam, ampli, ampliNo, vertFreq, horizFreq, readoutModeNo)


for (jf, cf, T) in (

    # int ncCamGetExposureTime(NcCam cam, int cameraRequest, double* exposureTime);
    (:getExposureTime, :ncCamGetExposureTime, Cdouble),

    # int ncCamGetWaitingTime(NcCam cam, int cameraRequest, double* waitingTime);
    (:getWaitingTime, :ncCamGetWaitingTime, Cdouble),

    # int ncCamGetShutterMode(NcCam cam, int cameraRequest, enum ShutterMode* shutterMode);
    (:getShutterMode, :ncCamGetShutterMode, ShutterMode),

    # int ncCamGetShutterPolarity(NcCam cam, int cameraRequest, enum ExtPolarity* shutterPolarity);
    (:getShutterPolarity, :ncCamGetShutterPolarity, ExtPolarity),

    # int ncCamGetExternalShutter(NcCam cam, int cameraRequest, enum ExtShutter* externalShutterPresence);
    (:getExternalShutter, :ncCamGetExternalShutter, ExtShutter),

    # int ncCamGetExternalShutterMode(NcCam cam, int cameraRequest, enum ShutterMode* externalShutterMode);
    (:getExternalShutterMode, :ncCamGetExternalShutterMode, ShutterMode),

    # int ncCamGetExternalShutterDelay(NcCam cam, int cameraRequest, double* externalShutterDelay);
    (:ncCamGetExternalShutterDelay, :ncCamGetExternalShutterDelay, Cdouble),

    # int ncCamGetFirePolarity(NcCam cam, int cameraRequest, enum ExtPolarity* firePolarity);
    (:getFirePolarity, :ncCamGetFirePolarity, ExtPolarity),

    # int ncCamGetOutputMinimumPulseWidth(NcCam cam, int cameraRequest, double *outputPulseWidth);
    (:getOutputMinimumPulseWidth, :ncCamGetOutputMinimumPulseWidth, Cdouble),

    # int ncCamGetArmPolarity(NcCam cam, int cameraRequest, enum ExtPolarity* armPolarity);
    (:getArmPolarity, :ncCamGetArmPolarity, ExtPolarity),

    # int ncCamGetCalibratedEmGain(NcCam cam, int cameraRequest, int *calibratedEmGain);
    (:getCalibratedEmGain, :ncCamGetCalibratedEmGain, Cint),

    # int ncCamGetRawEmGain(NcCam cam, int cameraRequest, int* rawEmGain);
    (:getRawEmGain, :ncCamGetRawEmGain, Cint),

    # int ncCamGetAnalogGain(NcCam cam, int cameraRequest, int* analogGain);
    (:getAnalogGain, :ncCamGetAnalogGain, Cint),

    # int ncCamGetAnalogOffset(NcCam cam, int cameraRequest, int* analogOffset);
    (:getAnalogOffset, :ncCamGetAnalogOffset, Cint),

    # int ncCamGetTargetDetectorTemp(NcCam cam, int cameraRequest, double* targetDetectorTemp);
    (:getTargetDetectorTemp, :ncCamGetTargetDetectorTemp, Cdouble),

    # int ncCamGetSerialCarTime(NcCam cam, int cameraRequest, double* serialCarTime);
    (:getSerialCarTime, :ncCamGetSerialCarTime, Cdouble))

    @eval begin

        @inline function $jf(cam::Cam, req::Bool)
            value = Ref{$T}()
            @call($cf, Status, (Cam, Cint, Ptr{$T}), cam, req, value)
            return value[]
        end

    end
end


#- # int ncCamSetTriggerMode(NcCam cam, enum TriggerMode triggerMode, int nbrImages);
#- @inline ncCamSetTriggerMode(cam::Cam, triggerMode::TriggerMode, nbrImages::Cint) =
#-     @call(:ncCamSetTriggerMode, Status,
#-           (Cam, TriggerMode, Cint),
#-           cam, triggerMode, nbrImages)

#- # int ncCamGetTriggerMode(NcCam cam, int cameraRequest, enum TriggerMode* triggerMode, int* nbrImagesPerTrig);
#- @inline ncCamGetTriggerMode(cam::Cam, cameraRequest::Cint, triggerMode::Ptr{TriggerMode}, nbrImagesPerTrig::Ptr{Cint}) =
#-     @call(:ncCamGetTriggerMode, Status,
#-           (Cam, Cint, Ptr{TriggerMode}, Ptr{Cint}),
#-           cam, cameraRequest, triggerMode, nbrImagesPerTrig)

#- # int ncCamGetComponentTemp(NcCam cam, enum NcTemperatureType temp, double * value);
#- @inline ncCamGetComponentTemp(cam::Cam, temp::TemperatureType, value::Ptr{Cdouble}) =
#-     @call(:ncCamGetComponentTemp, Status,
#-           (Cam, TemperatureType, Ptr{Cdouble}),
#-           cam, temp, value)

#- # int ncCamGetSerialNumber(NcCam cam, char *sn);
#- @inline ncCamGetSerialNumber(cam::Cam, sn::Ptr{Cchar}) =
#-     @call(:ncCamGetSerialNumber, Status,
#-           (Cam, Ptr{Cchar}),
#-           cam, sn)

#- # int ncCamDetectorTypeEnumToString(enum DetectorType detectorType, const char** str);
#- @inline ncCamDetectorTypeEnumToString(detectorType::DetectorType, str::Ptr{Ptr{Cchar}}) =
#-     @call(:ncCamDetectorTypeEnumToString, Status,
#-           (DetectorType, Ptr{Ptr{Cchar}}),
#-           detectorType, str)

#- # int ncCamSetBinningMode(NcCam cam, int binXValue, int binYValue);
#- @inline ncCamSetBinningMode(cam::Cam, binXValue::Cint, binYValue::Cint) =
#-     @call(:ncCamSetBinningMode, Status,
#-           (Cam, Cint, Cint),
#-           cam, binXValue, binYValue)

#- # int ncCamSetMRoiSize(NcCam cam, int index, int width, int height);
#- @inline ncCamSetMRoiSize(cam::Cam, index::Cint, width::Cint, height::Cint) =
#-     @call(:ncCamSetMRoiSize, Status,
#-           (Cam, Cint, Cint, Cint),
#-           cam, index, width, height)

#- # int ncCamGetMRoiSize(NcCam cam, int index, int * width, int * height);
#- @inline ncCamGetMRoiSize(cam::Cam, index::Cint, width::Ptr{Cint}, height::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiSize, Status,
#-           (Cam, Cint, Ptr{Cint}, Ptr{Cint}),
#-           cam, index, width, height)

#- # int ncCamSetMRoiPosition(NcCam cam, int index, int offsetX, int offsetY);
#- @inline ncCamSetMRoiPosition(cam::Cam, index::Cint, offsetX::Cint, offsetY::Cint) =
#-     @call(:ncCamSetMRoiPosition, Status,
#-           (Cam, Cint, Cint, Cint),
#-           cam, index, offsetX, offsetY)

#- # int ncCamGetMRoiPosition(NcCam cam, int index, int * offsetX, int * offsetY);
#- @inline ncCamGetMRoiPosition(cam::Cam, index::Cint, offsetX::Ptr{Cint}, offsetY::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiPosition, Status,
#-           (Cam, Cint, Ptr{Cint}, Ptr{Cint}),
#-           cam, index, offsetX, offsetY)

#- # int ncCamAddMRoi(NcCam cam, int offsetX, int offsetY, int width, int height);
#- @inline ncCamAddMRoi(cam::Cam, offsetX::Cint, offsetY::Cint, width::Cint, height::Cint) =
#-     @call(:ncCamAddMRoi, Status,
#-           (Cam, Cint, Cint, Cint, Cint),
#-           cam, offsetX, offsetY, width, height)

for (jf, cf) in (
    # int ncCamGetMRoiInputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
    (:getMRoiInputRegion, :ncCamGetMRoiInputRegion),

    # int ncCamGetMRoiOutputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
    (:getMRoiOutputRegion, :ncCamGetMRoiOutputRegion))

    @eval begin

        function $jf(params::ImageParams{Cam}, index::Integer)
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
end

#- # int ncCamGetMRoiRegionCount(ImageParams params, int * count);
#- @inline ncCamGetMRoiRegionCount(params::ImageParams, count::Ptr{Cint}) =
#-     @call(:ncCamGetMRoiRegionCount, Status,
#-           (ImageParams, Ptr{Cint}),
#-           params, count)

#- # int ncCamMRoiHasChanges(NcCam cam, int * hasChanges);
#- @inline ncCamMRoiHasChanges(cam::Cam, hasChanges::Ptr{Cint}) =
#-     @call(:ncCamMRoiHasChanges, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, hasChanges)

#- # int ncCamMRoiCanApplyWithoutStop(NcCam cam, int * nonStop);
#- @inline ncCamMRoiCanApplyWithoutStop(cam::Cam, nonStop::Ptr{Cint}) =
#-     @call(:ncCamMRoiCanApplyWithoutStop, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, nonStop)

#- # int ncCamGetVersion(NcCam cam, enum VersionType versionType, char * version, int bufferSize);
#- @inline ncCamGetVersion(cam::Cam, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
#-     @call(:ncCamGetVersion, Status,
#-           (Cam, VersionType, Ptr{Cchar}, Cint),
#-           cam, versionType, version, bufferSize)

#- # int ncCamNbrImagesAcquired(NcCam cam, int *nbrImages);
#- @inline ncCamNbrImagesAcquired(cam::Cam, nbrImages::Ptr{Cint}) =
#-     @call(:ncCamNbrImagesAcquired, Status,
#-           (Cam, Ptr{Cint}),
#-           cam, nbrImages)

#- # int ncCamGetSafeShutdownTemperature(NcCam cam, double *safeTemperature, int *dontCare);
#- @inline ncCamGetSafeShutdownTemperature(cam::Cam, safeTemperature::Ptr{Cdouble}, dontCare::Ptr{Cint}) =
#-     @call(:ncCamGetSafeShutdownTemperature, Status,
#-           (Cam, Ptr{Cdouble}, Ptr{Cint}),
#-           cam, safeTemperature, dontCare)

#- # int ncCamSetCropMode( NcCam cam, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY );
#- @inline ncCamSetCropMode(cam::Cam, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint) =
#-     @call(:ncCamSetCropMode, Status,
#-           (Cam, CropMode, Cint, Cint),
#-           cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

#- # int ncCamGetCropMode( NcCam cam, enum CropMode* mode, int* paddingPixelsMinimumX, int* paddingPixelsMinimumY, float* figureOfMerit);
#- @inline ncCamGetCropMode(cam::Cam, mode::Ptr{CropMode}, paddingPixelsMinimumX::Ptr{Cint}, paddingPixelsMinimumY::Ptr{Cint}, figureOfMerit::Ptr{Cfloat}) =
#-     @call(:ncCamGetCropMode, Status,
#-           (Cam, Ptr{CropMode}, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}),
#-           cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY, figureOfMerit)

#- # int ncCropModeSolutionsOpen( NcCropModeSolutions* solutionSet, int cropWidth, int cropHeight, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY, NcCam cam);
#- @inline ncCropModeSolutionsOpen(solutionSet::Ptr{CropModeSolutions}, cropWidth::Cint, cropHeight::Cint, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint, cam::Cam) =
#-     @call(:ncCropModeSolutionsOpen, Status,
#-           (Ptr{CropModeSolutions}, Cint, Cint, CropMode, Cint, Cint, Cam),
#-           solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY, cam)

#- # int ncCropModeSolutionsRefresh( NcCropModeSolutions solutionSet );
#- @inline ncCropModeSolutionsRefresh(solutionSet::CropModeSolutions) =
#-     @call(:ncCropModeSolutionsRefresh, Status,
#-           (CropModeSolutions, ),
#-           solutionSet)

#- # int ncCropModeSolutionsSetParameters( NcCropModeSolutions solutionSet, int cropWidth, int cropHeight, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY);
#- @inline ncCropModeSolutionsSetParameters(solutionSet::CropModeSolutions, cropWidth::Cint, cropHeight::Cint, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint) =
#-     @call(:ncCropModeSolutionsSetParameters, Status,
#-           (CropModeSolutions, Cint, Cint, CropMode, Cint, Cint),
#-           solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

#- # int ncCropModeSolutionsGetParameters( NcCropModeSolutions solutionSet, int* cropWidth, int* cropHeight, enum CropMode* mode, int* paddingPixelsMinimumX, int* paddingPixelsMinimumY);
#- @inline ncCropModeSolutionsGetParameters(solutionSet::CropModeSolutions, cropWidth::Ptr{Cint}, cropHeight::Ptr{Cint}, mode::Ptr{CropMode}, paddingPixelsMinimumX::Ptr{Cint}, paddingPixelsMinimumY::Ptr{Cint}) =
#-     @call(:ncCropModeSolutionsGetParameters, Status,
#-           (CropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{CropMode}, Ptr{Cint}, Ptr{Cint}),
#-           solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

#- # int ncCropModeSolutionsGetTotal( NcCropModeSolutions solutionSet, int* totalNbrSolutions);
#- @inline ncCropModeSolutionsGetTotal(solutionSet::CropModeSolutions, totalNbrSolutions::Ptr{Cint}) =
#-     @call(:ncCropModeSolutionsGetTotal, Status,
#-           (CropModeSolutions, Ptr{Cint}),
#-           solutionSet, totalNbrSolutions)

#- # int ncCropModeSolutionsGetResult( NcCropModeSolutions solutionSet, unsigned int solutionIndex, float* figureOfMerit, int* startX_min, int* startX_max, int* startY_min, int* startY_max);
#- @inline ncCropModeSolutionsGetResult(solutionSet::CropModeSolutions, solutionIndex::Cuint, figureOfMerit::Ptr{Cfloat}, startX_min::Ptr{Cint}, startX_max::Ptr{Cint}, startY_min::Ptr{Cint}, startY_max::Ptr{Cint}) =
#-     @call(:ncCropModeSolutionsGetResult, Status,
#-           (CropModeSolutions, Cuint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
#-           solutionSet, solutionIndex, figureOfMerit, startX_min, startX_max, startY_min, startY_max)

#- # int ncCropModeSolutionsGetLocationRanges( NcCropModeSolutions solutionSet, int *offsetX_min, int *offsetX_max, int *offsetY_min, int *offsetY_max);
#- @inline ncCropModeSolutionsGetLocationRanges(solutionSet::CropModeSolutions, offsetX_min::Ptr{Cint}, offsetX_max::Ptr{Cint}, offsetY_min::Ptr{Cint}, offsetY_max::Ptr{Cint}) =
#-     @call(:ncCropModeSolutionsGetLocationRanges, Status,
#-           (CropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
#-           solutionSet, offsetX_min, offsetX_max, offsetY_min, offsetY_max)

#- # int ncCropModeSolutionsGetResultAtLocation( NcCropModeSolutions solutionSet, int offsetX, int offsetY, float *figureOfMerit, int *startX_min, int *startX_max, int *startY_min, int *startY_max);
#- @inline ncCropModeSolutionsGetResultAtLocation(solutionSet::CropModeSolutions, offsetX::Cint, offsetY::Cint, figureOfMerit::Ptr{Cfloat}, startX_min::Ptr{Cint}, startX_max::Ptr{Cint}, startY_min::Ptr{Cint}, startY_max::Ptr{Cint}) =
#-     @call(:ncCropModeSolutionsGetResultAtLocation, Status,
#-           (CropModeSolutions, Cint, Cint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
#-           solutionSet, offsetX, offsetY, figureOfMerit, startX_min, startX_max, startY_min, startY_max)

#- # int ncCropModeSolutionsClose( NcCropModeSolutions solutionSet );
#- @inline ncCropModeSolutionsClose(solutionSet::CropModeSolutions) =
#-     @call(:ncCropModeSolutionsClose, Status,
#-           (CropModeSolutions, ),
#-           solutionSet)

#- # int ncCamCreateBias(NcCam cam, int nbrImages, enum ShutterMode biasShuttermode);
#- @inline ncCamCreateBias(cam::Cam, nbrImages::Cint, biasShuttermode::ShutterMode) =
#-     @call(:ncCamCreateBias, Status,
#-           (Cam, Cint, ShutterMode),
#-           cam, nbrImages, biasShuttermode)

#- # int ncCamGetProcType(NcCam cam, int * type, int * nbrImagesPc);
#- @inline ncCamGetProcType(cam::Cam, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
#-     @call(:ncCamGetProcType, Status,
#-           (Cam, Ptr{Cint}, Ptr{Cint}),
#-           cam, _type, nbrImagesPc)

#- # int ncCamSetProcType(NcCam cam, int type, int nbrImagesPc);
#- @inline ncCamSetProcType(cam::Cam, _type::Cint, nbrImagesPc::Cint) =
#-     @call(:ncCamSetProcType, Status,
#-           (Cam, Cint, Cint),
#-           cam, _type, nbrImagesPc)

#- # int ncCamCreateBiasNewImageCallback(NcCam cam, void (*fct)(NcCam cam, int imageNo, void *data), void *data);
#- @inline ncCamCreateBiasNewImageCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamCreateBiasNewImageCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamStatsAddRegion(NcCam cam, int regionWidth, int regionHeight, int *regionIndex);
#- @inline ncCamStatsAddRegion(cam::Cam, regionWidth::Cint, regionHeight::Cint, regionIndex::Ptr{Cint}) =
#-     @call(:ncCamStatsAddRegion, Status,
#-           (Cam, Cint, Cint, Ptr{Cint}),
#-           cam, regionWidth, regionHeight, regionIndex)

#- # int ncCamStatsRemoveRegion(NcCam cam, int regionIndex);
#- @inline ncCamStatsRemoveRegion(cam::Cam, regionIndex::Cint) =
#-     @call(:ncCamStatsRemoveRegion, Status,
#-           (Cam, Cint),
#-           cam, regionIndex)

#- # int ncCamStatsResizeRegion(NcCam cam, int regionIndex, int regionWidth, int regionHeight);
#- @inline ncCamStatsResizeRegion(cam::Cam, regionIndex::Cint, regionWidth::Cint, regionHeight::Cint) =
#-     @call(:ncCamStatsResizeRegion, Status,
#-           (Cam, Cint, Cint, Cint),
#-           cam, regionIndex, regionWidth, regionHeight)

#- # int ncCamStatsGetCrossSection(NcCam cam, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
#- @inline ncCamStatsGetCrossSection(cam::Cam, regionIndex::Cint, image::Ptr{Image}, xCoord::Cint, yCoord::Cint, statsCtxRegion::Ptr{Cdouble}, histo::Ptr{Ptr{Cdouble}}, crossSectionHorizontal::Ptr{Ptr{Cdouble}}, crossSectionVertical::Ptr{Ptr{Cdouble}}) =
#-     @call(:ncCamStatsGetCrossSection, Status,
#-           (Cam, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
#-           cam, regionIndex, image, xCoord, yCoord, statsCtxRegion, histo, crossSectionHorizontal, crossSectionVertical)

#- # int ncCamStatsGetGaussFit(NcCam cam, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSection);
#- @inline ncCamStatsGetGaussFit(cam::Cam, regionIndex::Cint, image::Ptr{Image}, xCoord::Cint, yCoord::Cint, maxAmplitude::Ptr{Cdouble}, gaussSumHorizontal::Ptr{Cdouble}, gaussSumVertical::Ptr{Cdouble}, useActualCrossSection::Cint) =
#-     @call(:ncCamStatsGetGaussFit, Status,
#-           (Cam, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
#-           cam, regionIndex, image, xCoord, yCoord, maxAmplitude, gaussSumHorizontal, gaussSumVertical, useActualCrossSection)

#- # int ncCamSetOnStatusAlertCallback(NcCam cam, void (*fct)(NcCam cam, void* data, int errorCode, const char * errorString), void * data);
#- @inline ncCamSetOnStatusAlertCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSetOnStatusAlertCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

#- # int ncCamSetOnStatusUpdateCallback(NcCam cam, void (*fct)(NcCam cam, void* data), void * data);
#- @inline ncCamSetOnStatusUpdateCallback(cam::Cam, fct::Ptr{Void}, data::Ptr{Void}) =
#-     @call(:ncCamSetOnStatusUpdateCallback, Status,
#-           (Cam, Ptr{Void}, Ptr{Void}),
#-           cam, fct, data)

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

    @eval begin

        $jf(ctx::Proc) = @call($cf, Status, (Proc,), ctx)

    end
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

    @eval begin

        @eval $jf(ctx::Proc, value::$Tj) =
            @call($cf, Status, (Proc, $Tc), ctx, value)
    end
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

    @eval begin

        function $jf(ctx::Proc)
            value = Ref{$T}()
            @call($jf, Status, (Proc, Ptr{$T}), ctx, value)
            return value[]
        end

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

setSaveHeaderCallback(ctx::Proc, fct::Ptr{Void}, data::Ptr{Void}) =
    # int ncProcSaveSetHeaderCallback(NcProc ctx, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
    @call(:ncProcSaveSetHeaderCallback, Status, (Proc, Ptr{Void}, Ptr{Void}),
          ctx, fct, data)

setLoadHeaderCallback(ctx::Proc, fct::Ptr{Void}, data::Ptr{Void}) =
# int ncProcLoadSetHeaderCallback(NcProc ctx, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
    @call(:ncProcLoadSetHeaderCallback, Status, (Proc, Ptr{Void}, Ptr{Void}),
          ctx, fct, data)

#------------------------------------------------------------------------------
# STATISTICAL FUNCTIONS

@inline function open(::Type{StatsCtx}, imageWidth::Integer, imageHeight::Integer)
    statsCtx = Ref{StatsCtx}()
    # int ncStatsOpen(int imageWidth, int imageHeight, NcStatsCtx** statsCtx);
    @call(:ncStatsOpen, Status, (Cint, Cint, Ptr{StatsCtx}),
          imageWidth, imageHeight, statsCtx)
    return statsCtx[]
end

@inline close(statsCtx::StatsCtx) =
    # int ncStatsClose(NcStatsCtx *statsCtx);
    @call(:ncStatsClose, Status, (StatsCtx, ), statsCtx)

@inline resize(statsCtx::StatsCtx, imageWidth::Integer, imageHeight::Integer) =
    # int ncStatsResize(NcStatsCtx *statsCtx, int imageWidth, int imageHeight);
    @call(:ncStatsResize, Status, (StatsCtx, Cint, Cint),
          statsCtx, imageWidth, imageHeight)

@inline function addRegion(statsCtx::StatsCtx, regionWidth::Integer, regionHeight::Integer)
    regionIndex = Ref{Cint}()
    # int ncStatsAddRegion(NcStatsCtx *statsCtx, int regionWidth, int regionHeight, int *regionIndex);
    @call(:ncStatsAddRegion, Status,
          (StatsCtx, Cint, Cint, Ptr{Cint}),
          statsCtx, regionWidth, regionHeight, regionIndex)
    return regionIndex[]
end

@inline removeRegion(statsCtx::StatsCtx, regionIndex::Integer) =
    # int ncStatsRemoveRegion(NcStatsCtx *statsCtx, int regionIndex);
    @call(:ncStatsRemoveRegion, Status, (StatsCtx, Cint), statsCtx, regionIndex)

@inline resizeRegion(statsCtx::StatsCtx, regionIndex::Integer, regionWidth::Integer, regionHeight::Integer) =
    # int ncStatsResizeRegion(NcStatsCtx *statsCtx, int regionIndex, int regionWidth, int regionHeight);
    @call(:ncStatsResizeRegion, Status, (StatsCtx, Cint, Cint, Cint),
          statsCtx, regionIndex, regionWidth, regionHeight)

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

"""
function getHistoCrossSection(statsCtx::StatsCtx, regionIndex::Integer, image::Ptr{Image},
                              xCoord::Integer, yCoord::Integer)
    # int ncStatsGetHistoCrossSection(NcStatsCtx *statsCtx, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
    stats = Array{Cdouble}(5)
    histo = Ref{Ptr{Cdouble}}()
    crossSectionHorizontal = Ref{Ptr{Cdouble}}()
    crossSectionVertical = Ref{Ptr{Cdouble}}()
    @call(:ncStatsGetHistoCrossSection, Status,
          (StatsCtx, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
          statsCtx, regionIndex, image, xCoord, yCoord, stats, histo, crossSectionHorizontal, crossSectionVertical)
    return stats, histo[], crossSectionHorizontal[], crossSectionVertical[]
    arr = Array{Cdouble}(65536)
end

function getGaussFit(statsCtx::StatsCtx, regionIndex::Integer, image::Ptr{Image},
                     xCoord::Integer, yCoord::Integer, useActualCrossSection::Bool)
    maxAmplitude = Ref{Cdouble}()
    gaussSumHorizontal = Array{Cdouble}(3)
    gaussSumVertical = Array{Cdouble}(3)
    # int ncStatsGetGaussFit(NcStatsCtx *statsCtx, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSectionFlag);
    @call(:ncStatsGetGaussFit, Status,
          (StatsCtx, Cint, Ptr{Image}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
          statsCtx, regionIndex, image, xCoord, yCoord, maxAmplitude,
          gaussSumHorizontal, gaussSumVertical, useActualCrossSection)
    return maxAmplitude[], gaussSumHorizontal, gaussSumVertical
end


#------------------------------------------------------------------------------
# PARAMETERS

getParam(::Type{Bool}, src::Union{Grab,Cam}, name::Name) =
    (getParamInt(src, name) != 0)

getParam(::Type{T}, src::Union{Grab,Cam}, name::Name) where {T<:Integer} =
    convert(T, getParamInt(src, name))

getParam(::Type{T}, src::Union{Grab,Cam}, name::Name) where {T<:AbstractFloat} =
    convert(T, getParamDbl(src, name))

function getParam(::Type{String}, src::Union{Grab,Cam}, name::Name)
    siz = getParamStrSize(src, name)
    buf = Array{Cchar}(siz + 1) # FIXME: check this!
    getParamStr(src, name, buf)
    buf[end] = 0
    return unsafe_string(pointer(buf)) # FIXME: is there a better way?
end

getParam(::Type{Function}, src::Union{Grab,Cam}, name::Name) =
    getParamCallback(src, name)


for (jf, cf) in (

    # int ncGrabParamGetCountInt(NcGrab grab, int * count);
    # int ncCamParamGetCountInt(NcCam cam, int * count);
    (:getParamCountInt, :ParamGetCountInt),

    # int ncGrabParamGetCountDbl(NcGrab grab, int * count);
    # int ncCamParamGetCountDbl(NcCam cam, int * count);
    (:getParamCountDbl, :ParamGetCountDbl),

    # int ncGrabParamGetCountStr(NcGrab grab, int * count);
    # int ncCamParamGetCountStr(NcCam cam, int * count);
    (:getParamCountStr, :ParamGetCountStr),

    # int ncGrabParamGetCountVoidPtr(NcGrab grab, int * count);
    # int ncCamParamGetCountVoidPtr(NcCam cam, int * count);
    (:getParamCountVoidPtr, :ParamGetCountVoidPtr),

    # int ncGrabParamGetCountCallback(NcGrab grab, int * count);
    # int ncCamParamGetCountCallback(NcCam cam, int * count);
    (:getParamCountCallback, :ParamGetCountCallback))

    @eval begin

        @inline function $jf(grab::Grab)
            value = Ref{Cint}()
            @call($(Symbol(:Grab,cf)), Status, (Grab, Ptr{Cint}), grab, value)
            return value[]
        end

        @inline function $jf(cam::Cam)
            value = Ref{Cint}()
            @call($(Symbol(:Cam,cf)), Status, (Cam, Ptr{Cint}), cam, value)
            return value[]
        end

    end
end

for (jf, cf) in (

    # int ncGrabParamSupportedInt(NcGrab grab, const char * paramName, int * supported);
    # int ncCamParamSupportedInt(NcCam cam, const char * paramName, int * supported);
    (:supportedParamInt, :ParamSupportedInt),

    # int ncGrabParamSupportedDbl(NcGrab grab, const char * paramName, int * supported);
    # int ncCamParamSupportedDbl(NcCam cam, const char * paramName, int * supported);
    (:supportedParamDbl, :ParamSupportedDbl),

    # int ncGrabParamSupportedStr(NcGrab grab, const char * paramName, int * supported);
    # int ncCamParamSupportedStr(NcCam cam, const char * paramName, int * supported);
    (:supportedParamStr, :ParamSupportedStr),

    # int ncGrabParamSupportedVoidPtr(NcGrab grab, const char * paramName, int * supported);
    # int ncCamParamSupportedVoidPtr(NcCam cam, const char * paramName, int * supported);
    (:supportedParamVoidPtr, :ParamSupportedVoidPtr),

    # int ncGrabParamSupportedCallback(NcGrab grab, const char * paramName, int * supported);
    # int ncCamParamSupportedCallback(NcCam cam, const char * paramName, int * supported);
    (:supportedParamCallback, :ParamSupportedCallback))

    @eval begin

        @inline function $jf(grab::Grab, name::Name)
            flag = Ref{Cint}()
            @call($(Symbol(:ncGrab,cf)), Status, (Grab, Cstring, Ptr{Cint}), grab, name, flag)
            return (flag[] != 0)
        end

        @inline function $jf(cam::Cam, name::Name)
            flag = Ref{Cint}()
            @call($(Symbol(:ncCam,cf)), Status, (Cam, Cstring, Ptr{Cint}), cam, name, flag)
            return (flag[] != 0)
        end

    end
end

for (jf, cf) in (

    # int ncGrabParamGetNameInt(NcGrab grab, int index, const char ** name);
    # int ncCamParamGetNameInt(NcCam cam, int index, const char ** name);
    (:getParamNameInt, :ParamGetNameInt),

    # int ncGrabParamGetNameDbl(NcGrab grab, int index, const char ** name);
    # int ncCamParamGetNameDbl(NcCam cam, int index, const char ** name);
    (:getParamNameDbl, :ParamGetNameDbl),

    # int ncGrabParamGetNameStr(NcGrab grab, int index, const char ** name);
    # int ncCamParamGetNameStr(NcCam cam, int index, const char ** name);
    (:getParamNameStr, :ParamGetNameStr),

    # int ncGrabParamGetNameVoidPtr(NcGrab grab, int index, const char ** name);
    # int ncCamParamGetNameVoidPtr(NcCam cam, int index, const char ** name);
    (:getParamNameVoidPtr, :ParamGetNameVoidPtr),

    # int ncGrabParamGetNameCallback(NcGrab grab, int index, const char ** name);
    # int ncCamParamGetNameCallback(NcCam cam, int index, const char ** name);
    (:getParamNameCallback, :ParamGetNameCallback))

    @eval begin

        @inline function $jf(grab::Grab, index::Integer)
            ptr = Ref{Ptr{Cchar}}()
            @call($(Symbol(:ncGrab,cf)), Status, (Grab, Cint, Ptr{Ptr{Cchar}}), grab, index, ptr)
            return unsafe_string(ptr[])
        end

        @inline function $jf(cam::Cam, index::Integer)
            ptr = Ref{Ptr{Cchar}}()
            @call($(Symbol(:ncCam,cf)), Status, (Cam, Cint, Ptr{Ptr{Cchar}}), cam, index, ptr)
            return unsafe_string(ptr[])
        end

    end
end

for (jf, Tj, cf, Tc) in (

    # int ncGrabParamSetInt(NcGrab grab, const char * paramName, int value);
    # int ncCamParamSetInt(NcCam cam, const char * paramName, int value);
    (:setParamInt, Integer, :ParamSetInt, Cint),

    # int ncGrabParamSetDbl(NcGrab grab, const char * paramName, double value);
    # int ncCamParamSetDbl(NcCam cam, const char * paramName, double value);
    (:setParamDbl, Real, :ParamSetDbl, Cdouble),

    # int ncGrabParamSetStr(NcGrab grab, const char * paramName, const char * value);
    # int ncCamParamSetStr(NcCam cam, const char * paramName, const char * value);
    (:setParamStr, Name, :ParamSetStr, Cstring),

    # int ncGrabParamSetVoidPtr(NcGrab grab, const char * paramName, void * value);
    # int ncCamParamSetVoidPtr(NcCam cam, const char * paramName, void * value);
    (:setParamVoidPtr, Ptr, :ParamSetVoidPtr, Ptr{Void}))

    @eval begin

        @inline $jf(grab::Grab, name::Name, value::$Tj) =
            @call($(Symbol(:ncGrab,cf)), Status, (Grab, Cstring, $Tc), grab, name, value)

        @inline $jf(cam::Cam, name::Name, value::$Tj) =
            @call($(Symbol(:ncCam,cf)), Status, (Cam, Cstring, $Tc), cam, name, value)

    end
end

# int ncGrabParamSetCallback(NcGrab grab, const char * paramName, void(*callback)(void*), void * data);
@inline setParamCallback(grab::Grab, name::Name, fct::Ptr{Void}, data::Ptr{Void}) =
    @call(:ncGrabParamSetCallback, Status, (Grab, Ptr{Cchar}, Ptr{Void}, Ptr{Void}),
          grab, name, fct, data)

# int ncCamParamSetCallback(NcCam cam, const char * paramName, void(*callback)(void*), void * data);
@inline setParamCallback(cam::Cam, name::Name, fct::Ptr{Void}, data::Ptr{Void}) =
    @call(:ncCamParamSetCallback, Status, (Cam, Ptr{Cchar}, Ptr{Void}, Ptr{Void}),
          cam, name, fct, data)

for (jf, cf) in (

    # int ncGrabParamUnsetInt(NcGrab grab, const char * paramName);
    # int ncCamParamUnsetInt(NcCam cam, const char * paramName);
    (:unsetParamInt, :ParamUnsetInt),

    # int ncGrabParamUnsetDbl(NcGrab grab, const char * paramName);
    # int ncCamParamUnsetDbl(NcCam cam, const char * paramName);
    (:unsetParamDbl, :ParamUnsetDbl),

    # int ncGrabParamUnsetStr(NcGrab grab, const char * paramName);
    # int ncCamParamUnsetStr(NcCam cam, const char * paramName);
    (:unsetParamStr, :ParamUnsetStr),

    # int ncGrabParamUnsetVoidPtr(NcGrab grab, const char * paramName);
    # int ncCamParamUnsetVoidPtr(NcCam cam, const char * paramName);
    (:unsetParamVoidPtr, :ParamUnsetVoidPtr),

    # int ncGrabParamUnsetCallback(NcGrab grab, const char * paramName);
    # int ncCamParamUnsetCallback(NcCam cam, const char * paramName);
    (:unsetParamCallback, :ParamUnsetCallback))

    @eval begin

        @inline $jf(grab::Grab, name::Name) =
            @call($(Symbol(:ncGrab,cf)), Status, (Grab, Cstring), grab, name)

        @inline $jf(cam::Cam, name::Name) =
            @call($(Symbol(:ncCam,cf)), Status, (Cam, Cstring), cam, name)

    end
end


for (jf, cf, T) in (

    # int ncGrabParamGetInt(NcGrab grab, const char * paramName, int * value);
    # int ncCamParamGetInt(NcCam cam, const char* paramName, int* value);
    (:getParamInt, :ParamGetInt, Cint),

    # int ncGrabParamGetDbl(NcGrab grab, const char * paramName, double * value);
    # int ncCamParamGetDbl(NcCam cam, const char* paramName, double* value);
    (:getParamDbl, :ParamGetDbl, Cdouble),

    # int ncGrabParamGetStrSize(NcGrab grab, const char * paramName, int * valueSize);
    # int ncCamParamGetStrSize(NcCam cam, const char * paramName, int * valueSize);
    (:getParamStrSize, :ParamGetStrSize, Cint),

    # int ncGrabParamGetVoidPtr(NcGrab grab, const char * paramName, void ** value);
    # int ncCamParamGetVoidPtr(NcCam cam, const char* paramName, void** value);
    (:getParamVoidPtr, :ParamGetVoidPtr, Ptr{Void}))

    @eval begin

        @inline function $jf(grab::Grab, name::Name)
            value = ref{$T}()
            @call($(Symbol(:ncGrab,cf)), Status, (Grab, Cstring, Ptr{$T}), grab, name, value)
            return value[]
        end

        @inline function $jf(cam::Cam, name::Name)
            value = ref{$T}()
            @call($(Symbol(:ncCam,cf)), Status, (Cam, Cstring, Ptr{$T}), cam, name, value)
            return value[]
        end

    end
end

# int ncGrabParamGetStr(NcGrab grab, const char * paramName, char * outBuffer, int bufferSize);
@inline getParamStr(grab::Grab, name::Name, buf::Array{Cchar}) =
    @call(:ncGrabParamGetStr, Status, (Grab, Cstring, Ptr{Cchar}, Cint),
          grab, name, buf, sizeof(buf))

# int ncCamParamGetStr(NcCam cam, const char* paramName, char* outBuffer, int bufferSize);
@inline getParamStr(cam::Cam, name::Name, buf::Array{Cchar}) =
    @call(:ncCamParamGetStr, Status, (Cam, Cstring, Ptr{Cchar}, Cint),
          cam, name, buf, sizeof(buf))

# int ncGrabParamGetCallback(NcGrab grab, const char * paramName, void(**callback)(void*), void ** data);
@inline function getParamCallback(grab::Grab, name::Name)
    fct = Ref{Ptr{Void}}()
    data = Ref{Ptr{Void}}()
    @call(:ncGrabParamGetCallback, Status,
          (Grab, Cstring, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}),
          grab, name, fct, data)
    return fct[], data[]
end

# int ncCamParamGetCallback(NcCam cam, const char * paramName, void(**callback)(void*), void ** data);
@inline function getParamCallback(cam::Cam, name::Name)
    fct = Ref{Ptr{Void}}()
    data = Ref{Ptr{Void}}()
    @call(:ncCamParamGetCallback, Status,
          (Cam, Cstring, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}),
          cam, name, fct, data)
    return fct[], data[]
end
