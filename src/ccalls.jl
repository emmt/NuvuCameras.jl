#
# ccalls.jl -
#
# Calls to C-API of Nüvü Camēras.
#

if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("Tcl not properly installed.  Please run `Pkg.build(\"NuvuCameras\")` to create file \"",joinpath(dirname(@__FILE__),"..","deps","deps.jl"),"\"")
end

# int ncWriteFileHeader(NcImageSaved *currentFile, enum HeaderDataType dataType, const char *name, const void *value, const char *comment);
@inline ncWriteFileHeader(currentFile::NcImageSaved, dataType::HeaderDataType, name::Ptr{Cchar}, value::Ptr{Void}, comment::Ptr{Cchar}) =
    ccall((:ncWriteFileHeader, libnuvu), Status,
          (NcImageSaved, HeaderDataType, Ptr{Cchar}, Ptr{Void}, Ptr{Cchar}),
          currentFile, dataType, name, value, comment)

# int ncReadFileHeader(NcImageSaved *currentFile, enum HeaderDataType dataType, const char *name, const void *value);
@inline ncReadFileHeader(currentFile::NcImageSaved, dataType::HeaderDataType, name::Ptr{Cchar}, value::Ptr{Void}) =
    ccall((:ncReadFileHeader, libnuvu), Status,
          (NcImageSaved, HeaderDataType, Ptr{Cchar}, Ptr{Void}),
          currentFile, dataType, name, value)

# int ncImageGetFileFormat(NcImageSaved *image, enum ImageFormat * format);
@inline ncImageGetFileFormat(image::NcImageSaved, format::Ptr{ImageFormat}) =
    ccall((:ncImageGetFileFormat, libnuvu), Status,
          (NcImageSaved, Ptr{ImageFormat}),
          image, format)

# int ncControllerListOpen(NcCtrlList * ctrlList);
@inline ncControllerListOpen(ctrlList::Ptr{NcCtrlList}) =
    ccall((:ncControllerListOpen, libnuvu), Status,
          (Ptr{NcCtrlList}, ),
          ctrlList)

# int ncControllerListOpenBasic(NcCtrlList * ctrlList);
@inline ncControllerListOpenBasic(ctrlList::Ptr{NcCtrlList}) =
    ccall((:ncControllerListOpenBasic, libnuvu), Status,
          (Ptr{NcCtrlList}, ),
          ctrlList)

# int ncControllerListFree(NcCtrlList ctrlList);
@inline ncControllerListFree(ctrlList::NcCtrlList) =
    ccall((:ncControllerListFree, libnuvu), Status,
          (NcCtrlList, ),
          ctrlList)

# int ncControllerListGetSize(const NcCtrlList ctrlList, int * listSize);
@inline ncControllerListGetSize(ctrlList::NcCtrlList, listSize::Ptr{Cint}) =
    ccall((:ncControllerListGetSize, libnuvu), Status,
          (NcCtrlList, Ptr{Cint}),
          ctrlList, listSize)

# int ncControllerListGetSerial(const NcCtrlList ctrlList, int index, char* serial, int serialSize);
@inline ncControllerListGetSerial(ctrlList::NcCtrlList, index::Cint, serial::Ptr{Cchar}, serialSize::Cint) =
    ccall((:ncControllerListGetSerial, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, serial, serialSize)

# int ncControllerListGetModel(const NcCtrlList ctrlList, int index, char* model, int modelSize);
@inline ncControllerListGetModel(ctrlList::NcCtrlList, index::Cint, model::Ptr{Cchar}, modelSize::Cint) =
    ccall((:ncControllerListGetModel, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, model, modelSize)

# int ncControllerListGetPortUnit(const NcCtrlList ctrlList, int index, int * unit);
@inline ncControllerListGetPortUnit(ctrlList::NcCtrlList, index::Cint, unit::Ptr{Cint}) =
    ccall((:ncControllerListGetPortUnit, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}),
          ctrlList, index, unit)

# int ncControllerListGetPortChannel(const NcCtrlList ctrlList, int index, int * channel);
@inline ncControllerListGetPortChannel(ctrlList::NcCtrlList, index::Cint, channel::Ptr{Cint}) =
    ccall((:ncControllerListGetPortChannel, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}),
          ctrlList, index, channel)

# int ncControllerListGetPortInterface(const NcCtrlList ctrlList, int index, char* acqInterface, int acqInterfaceSize);
@inline ncControllerListGetPortInterface(ctrlList::NcCtrlList, index::Cint, acqInterface::Ptr{Cchar}, acqInterfaceSize::Cint) =
    ccall((:ncControllerListGetPortInterface, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, acqInterface, acqInterfaceSize)

# int ncControllerListGetUniqueID(const NcCtrlList ctrlList, int index, char* uniqueID, int uniqueIDSize);
@inline ncControllerListGetUniqueID(ctrlList::NcCtrlList, index::Cint, uniqueID::Ptr{Cchar}, uniqueIDSize::Cint) =
    ccall((:ncControllerListGetUniqueID, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, uniqueID, uniqueIDSize)

# int ncControllerListGetFullSizeSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
@inline ncControllerListGetFullSizeSize(ctrlList::NcCtrlList, index::Cint, detectorSizeX::Ptr{Cint}, detectorSizeY::Ptr{Cint}) =
    ccall((:ncControllerListGetFullSizeSize, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}, Ptr{Cint}),
          ctrlList, index, detectorSizeX, detectorSizeY)

# int ncControllerListGetDetectorSize(const NcCtrlList ctrlList, int index, int* detectorSizeX, int* detectorSizeY);
@inline ncControllerListGetDetectorSize(ctrlList::NcCtrlList, index::Cint, detectorSizeX::Ptr{Cint}, detectorSizeY::Ptr{Cint}) =
    ccall((:ncControllerListGetDetectorSize, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}, Ptr{Cint}),
          ctrlList, index, detectorSizeX, detectorSizeY)

# int ncControllerListGetDetectorType(const NcCtrlList ctrlList, int index, char* detectorType, int detectorTypeSize);
@inline ncControllerListGetDetectorType(ctrlList::NcCtrlList, index::Cint, detectorType::Ptr{Cchar}, detectorTypeSize::Cint) =
    ccall((:ncControllerListGetDetectorType, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, detectorType, detectorTypeSize)

# int ncControllerListGetFreePortCount(const NcCtrlList ctrlList, int * portCount);
@inline ncControllerListGetFreePortCount(ctrlList::NcCtrlList, portCount::Ptr{Cint}) =
    ccall((:ncControllerListGetFreePortCount, libnuvu), Status,
          (NcCtrlList, Ptr{Cint}),
          ctrlList, portCount)

# int ncControllerListGetFreePortUnit(const NcCtrlList ctrlList, int index, int * unit);
@inline ncControllerListGetFreePortUnit(ctrlList::NcCtrlList, index::Cint, unit::Ptr{Cint}) =
    ccall((:ncControllerListGetFreePortUnit, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}),
          ctrlList, index, unit)

# int ncControllerListGetFreePortChannel(const NcCtrlList ctrlList, int index, int * channel);
@inline ncControllerListGetFreePortChannel(ctrlList::NcCtrlList, index::Cint, channel::Ptr{Cint}) =
    ccall((:ncControllerListGetFreePortChannel, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cint}),
          ctrlList, index, channel)

# int ncControllerListGetFreePortInterface(const NcCtrlList ctrlList, int index, char* acqInterface, int acqInterfaceSize);
@inline ncControllerListGetFreePortInterface(ctrlList::NcCtrlList, index::Cint, acqInterface::Ptr{Cchar}, acqInterfaceSize::Cint) =
    ccall((:ncControllerListGetFreePortInterface, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, acqInterface, acqInterfaceSize)

# int ncControllerListGetFreePortUniqueID(const NcCtrlList ctrlList, int index, char* uniqueID, int uniqueIDSize);
@inline ncControllerListGetFreePortUniqueID(ctrlList::NcCtrlList, index::Cint, uniqueID::Ptr{Cchar}, uniqueIDSize::Cint) =
    ccall((:ncControllerListGetFreePortUniqueID, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, uniqueID, uniqueIDSize)

# int ncControllerListGetFreePortReason(const NcCtrlList ctrlList, int index, enum NcPortUnusedReason* reason);
@inline ncControllerListGetFreePortReason(ctrlList::NcCtrlList, index::Cint, reason::Ptr{NcPortUnusedReason}) =
    ccall((:ncControllerListGetFreePortReason, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{NcPortUnusedReason}),
          ctrlList, index, reason)

# int ncControllerListGetPluginCount(const NcCtrlList ctrlList, int * listSize);
@inline ncControllerListGetPluginCount(ctrlList::NcCtrlList, listSize::Ptr{Cint}) =
    ccall((:ncControllerListGetPluginCount, libnuvu), Status,
          (NcCtrlList, Ptr{Cint}),
          ctrlList, listSize)

# int ncControllerListGetPluginName(const NcCtrlList ctrlList, int index, char* pluginName, int pluginNameSize);
@inline ncControllerListGetPluginName(ctrlList::NcCtrlList, index::Cint, pluginName::Ptr{Cchar}, pluginNameSize::Cint) =
    ccall((:ncControllerListGetPluginName, libnuvu), Status,
          (NcCtrlList, Cint, Ptr{Cchar}, Cint),
          ctrlList, index, pluginName, pluginNameSize)

# int ncGrabSetOpenMacAdress(char* macAddress);
@inline ncGrabSetOpenMacAdress(macAddress::Ptr{Cchar}) =
    ccall((:ncGrabSetOpenMacAdress, libnuvu), Status,
          (Ptr{Cchar}, ),
          macAddress)

# int ncGrabOpen(int unit, int channel, int nbrBuffer, NcGrab* grab);
@inline ncGrabOpen(unit::Cint, channel::Cint, nbrBuffer::Cint, grab::Ptr{NcGrab}) =
    ccall((:ncGrabOpen, libnuvu), Status,
          (Cint, Cint, Cint, Ptr{NcGrab}),
          unit, channel, nbrBuffer, grab)

# int ncGrabOpenFromList(const NcCtrlList ctrlList, int index, int nbrBuffer, NcGrab* grab);
@inline ncGrabOpenFromList(ctrlList::NcCtrlList, index::Cint, nbrBuffer::Cint, grab::Ptr{NcGrab}) =
    ccall((:ncGrabOpenFromList, libnuvu), Status,
          (NcCtrlList, Cint, Cint, Ptr{NcGrab}),
          ctrlList, index, nbrBuffer, grab)

# int ncGrabClose(NcGrab grab);
@inline ncGrabClose(grab::NcGrab) =
    ccall((:ncGrabClose, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabSetHeartbeat(NcGrab grab, int timeMs);
@inline ncGrabSetHeartbeat(grab::NcGrab, timeMs::Cint) =
    ccall((:ncGrabSetHeartbeat, libnuvu), Status,
          (NcGrab, Cint),
          grab, timeMs)

# int ncGrabGetHeartbeat(NcGrab grab, int *timeMs);
@inline ncGrabGetHeartbeat(grab::NcGrab, timeMs::Ptr{Cint}) =
    ccall((:ncGrabGetHeartbeat, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, timeMs)

# int ncGrabStart(NcGrab grab, int nbrImages);
@inline ncGrabStart(grab::NcGrab, nbrImages::Cint) =
    ccall((:ncGrabStart, libnuvu), Status,
          (NcGrab, Cint),
          grab, nbrImages)

# int ncGrabAbort(NcGrab grab);
@inline ncGrabAbort(grab::NcGrab) =
    ccall((:ncGrabAbort, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabRead(NcGrab grab, NcImage** imageAcqu);
@inline ncGrabRead(grab::NcGrab, imageAcqu::Ptr{Ptr{NcImage}}) =
    ccall((:ncGrabRead, libnuvu), Status,
          (NcGrab, Ptr{Ptr{NcImage}}),
          grab, imageAcqu)

# int ncGrabReadChronological(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
@inline ncGrabReadChronological(grab::NcGrab, imageAcqu::Ptr{Ptr{NcImage}}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncGrabReadChronological, libnuvu), Status,
          (NcGrab, Ptr{Ptr{NcImage}}, Ptr{Cint}),
          grab, imageAcqu, nbrImagesSkipped)

# int ncGrabReadChronologicalNonBlocking(NcGrab grab, NcImage** imageAcqu, int* nbrImagesSkipped);
@inline ncGrabReadChronologicalNonBlocking(grab::NcGrab, imageAcqu::Ptr{Ptr{NcImage}}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncGrabReadChronologicalNonBlocking, libnuvu), Status,
          (NcGrab, Ptr{Ptr{NcImage}}, Ptr{Cint}),
          grab, imageAcqu, nbrImagesSkipped)

# int ncGrabOpenImageParams(ImageParams *imageParams);
@inline ncGrabOpenImageParams(imageParams::Ptr{ImageParams}) =
    ccall((:ncGrabOpenImageParams, libnuvu), Status,
          (Ptr{ImageParams}, ),
          imageParams)

# int ncGrabGetImageParams(NcGrab grab, void* imageNc, ImageParams imageParams);
@inline ncGrabGetImageParams(grab::NcGrab, imageNc::Ptr{Void}, imageParams::ImageParams) =
    ccall((:ncGrabGetImageParams, libnuvu), Status,
          (NcGrab, Ptr{Void}, ImageParams),
          grab, imageNc, imageParams)

# int ncGrabCloseImageParams(ImageParams imageParams);
@inline ncGrabCloseImageParams(imageParams::ImageParams) =
    ccall((:ncGrabCloseImageParams, libnuvu), Status,
          (ImageParams, ),
          imageParams)

# int ncGrabFlushReadQueues(NcGrab grab);
@inline ncGrabFlushReadQueues(grab::NcGrab) =
    ccall((:ncGrabFlushReadQueues, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabGetOverrun(NcGrab grab, int* overrunOccurred);
@inline ncGrabGetOverrun(grab::NcGrab, overrunOccurred::Ptr{Cint}) =
    ccall((:ncGrabGetOverrun, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, overrunOccurred)

# int ncGrabGetNbrDroppedImages(NcGrab grab, int* nbrDroppedImages);
@inline ncGrabGetNbrDroppedImages(grab::NcGrab, nbrDroppedImages::Ptr{Cint}) =
    ccall((:ncGrabGetNbrDroppedImages, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, nbrDroppedImages)

# int ncGrabGetNbrTimeout(NcGrab grab, int* nbrTimeout);
@inline ncGrabGetNbrTimeout(grab::NcGrab, nbrTimeout::Ptr{Cint}) =
    ccall((:ncGrabGetNbrTimeout, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, nbrTimeout)

# int ncGrabSetTimeout(NcGrab grab, int timeMs);
@inline ncGrabSetTimeout(grab::NcGrab, timeMs::Cint) =
    ccall((:ncGrabSetTimeout, libnuvu), Status,
          (NcGrab, Cint),
          grab, timeMs)

# int ncGrabGetTimeout(NcGrab grab, int* timeTimeout);
@inline ncGrabGetTimeout(grab::NcGrab, timeTimeout::Ptr{Cint}) =
    ccall((:ncGrabGetTimeout, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, timeTimeout)

# int ncGrabSetSize(NcGrab grab, int width, int height);
@inline ncGrabSetSize(grab::NcGrab, width::Cint, height::Cint) =
    ccall((:ncGrabSetSize, libnuvu), Status,
          (NcGrab, Cint, Cint),
          grab, width, height)

# int ncGrabGetSize(NcGrab grab, int* width, int* height);
@inline ncGrabGetSize(grab::NcGrab, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncGrabGetSize, libnuvu), Status,
          (NcGrab, Ptr{Cint}, Ptr{Cint}),
          grab, width, height)

# int ncGrabSaveImage(NcGrab grab, const NcImage* imageNc, const char* saveName, enum ImageFormat saveFormat, int overwriteFlag);
@inline ncGrabSaveImage(grab::NcGrab, imageNc::Ptr{NcImage}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, overwriteFlag::Cint) =
    ccall((:ncGrabSaveImage, libnuvu), Status,
          (NcGrab, Ptr{NcImage}, Ptr{Cchar}, ImageFormat, Cint),
          grab, imageNc, saveName, saveFormat, overwriteFlag)

# int ncGrabSaveImageEx(NcGrab grab, const void* imageNc, const char* saveName, enum ImageFormat saveFormat, enum ImageDataType dataFormat, int overwriteFlag);
@inline ncGrabSaveImageEx(grab::NcGrab, imageNc::Ptr{Void}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, dataFormat::ImageDataType, overwriteFlag::Cint) =
    ccall((:ncGrabSaveImageEx, libnuvu), Status,
          (NcGrab, Ptr{Void}, Ptr{Cchar}, ImageFormat, ImageDataType, Cint),
          grab, imageNc, saveName, saveFormat, dataFormat, overwriteFlag)

# int ncGrabStartSaveAcquisition(NcGrab grab, const char *saveName, enum ImageFormat saveFormat, int imagesPerCubes, int nbrOfCubes, int overwriteFlag);
@inline ncGrabStartSaveAcquisition(grab::NcGrab, saveName::Ptr{Cchar}, saveFormat::ImageFormat, imagesPerCubes::Cint, nbrOfCubes::Cint, overwriteFlag::Cint) =
    ccall((:ncGrabStartSaveAcquisition, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, ImageFormat, Cint, Cint, Cint),
          grab, saveName, saveFormat, imagesPerCubes, nbrOfCubes, overwriteFlag)

# int ncGrabStopSaveAcquisition(NcGrab grab);
@inline ncGrabStopSaveAcquisition(grab::NcGrab) =
    ccall((:ncGrabStopSaveAcquisition, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabSaveImageSetHeaderCallback(NcGrab grab, void (*fct)(NcGrab grab, NcImageSaved *imageFile, void *data), void *data);
@inline ncGrabSaveImageSetHeaderCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabSaveImageSetHeaderCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabSaveImageWriteCallback(NcGrab grab, void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
@inline ncGrabSaveImageWriteCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabSaveImageWriteCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabSaveImageCloseCallback(NcGrab grab, void (*fct)(NcGrab grab, int fileNo, void *data), void *data);
@inline ncGrabSaveImageCloseCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabSaveImageCloseCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabSaveImageSetCompressionType(NcGrab grab, enum ImageCompression compress);
@inline ncGrabSaveImageSetCompressionType(grab::NcGrab, compress::ImageCompression) =
    ccall((:ncGrabSaveImageSetCompressionType, libnuvu), Status,
          (NcGrab, ImageCompression),
          grab, compress)

# int ncGrabSaveImageGetCompressionType(NcGrab grab, enum ImageCompression *compress);
@inline ncGrabSaveImageGetCompressionType(grab::NcGrab, compress::Ptr{ImageCompression}) =
    ccall((:ncGrabSaveImageGetCompressionType, libnuvu), Status,
          (NcGrab, Ptr{ImageCompression}),
          grab, compress)

# int ncGrabSaveParam(NcGrab grab, const char *saveName, int overwriteFlag);
@inline ncGrabSaveParam(grab::NcGrab, saveName::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncGrabSaveParam, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Cint),
          grab, saveName, overwriteFlag)

# int ncGrabLoadParam(NcGrab grab, const char *saveName);
@inline ncGrabLoadParam(grab::NcGrab, saveName::Ptr{Cchar}) =
    ccall((:ncGrabLoadParam, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, saveName)

# int ncGrabSaveParamSetHeaderCallback(NcGrab grab, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncGrabSaveParamSetHeaderCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabSaveParamSetHeaderCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabLoadParamSetHeaderCallback(NcGrab grab, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncGrabLoadParamSetHeaderCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabLoadParamSetHeaderCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabSetTimestampMode(NcGrab grab, enum TimestampMode timestampMode);
@inline ncGrabSetTimestampMode(grab::NcGrab, timestampMode::TimestampMode) =
    ccall((:ncGrabSetTimestampMode, libnuvu), Status,
          (NcGrab, TimestampMode),
          grab, timestampMode)

# int ncGrabGetTimestampMode(NcGrab grab, int ctrlRequest, enum TimestampMode *timestampMode, int *gpsSignalValid);
@inline ncGrabGetTimestampMode(grab::NcGrab, ctrlRequest::Cint, timestampMode::Ptr{TimestampMode}, gpsSignalValid::Ptr{Cint}) =
    ccall((:ncGrabGetTimestampMode, libnuvu), Status,
          (NcGrab, Cint, Ptr{TimestampMode}, Ptr{Cint}),
          grab, ctrlRequest, timestampMode, gpsSignalValid)

# int ncGrabSetTimestampInternal(NcGrab grab, struct tm *dateTime, int nbrUs);
@inline ncGrabSetTimestampInternal(grab::NcGrab, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
    ccall((:ncGrabSetTimestampInternal, libnuvu), Status,
          (NcGrab, Ptr{TmStruct}, Cint),
          grab, dateTime, nbrUs)

# int ncGrabGetCtrlTimestamp(NcGrab grab, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
@inline ncGrabGetCtrlTimestamp(grab::NcGrab, imageAcqu::Ptr{NcImage}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
    ccall((:ncGrabGetCtrlTimestamp, libnuvu), Status,
          (NcGrab, Ptr{NcImage}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
          grab, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

# int ncGrabGetHostSystemTimestamp(NcGrab grab, NcImage* imageAcqu, double *hostSystemTimestamp);
@inline ncGrabGetHostSystemTimestamp(grab::NcGrab, imageAcqu::Ptr{NcImage}, hostSystemTimestamp::Ptr{Cdouble}) =
    ccall((:ncGrabGetHostSystemTimestamp, libnuvu), Status,
          (NcGrab, Ptr{NcImage}, Ptr{Cdouble}),
          grab, imageAcqu, hostSystemTimestamp)

# int ncGrabParamAvailable(NcGrab grab, enum Features param, int setting);
@inline ncGrabParamAvailable(grab::NcGrab, param::Features, setting::Cint) =
    ccall((:ncGrabParamAvailable, libnuvu), Status,
          (NcGrab, Features, Cint),
          grab, param, setting)

# int ncGrabResetTimer(NcGrab grab, double timeOffset);
@inline ncGrabResetTimer(grab::NcGrab, timeOffset::Cdouble) =
    ccall((:ncGrabResetTimer, libnuvu), Status,
          (NcGrab, Cdouble),
          grab, timeOffset)

# int ncGrabSetEvent(NcGrab grab, NcCallbackFunc funcName, void* ncData);
@inline ncGrabSetEvent(grab::NcGrab, funcName::NcCallbackFunc, ncData::Ptr{Void}) =
    ccall((:ncGrabSetEvent, libnuvu), Status,
          (NcGrab, NcCallbackFunc, Ptr{Void}),
          grab, funcName, ncData)

# int ncGrabCancelEvent(NcGrab grab);
@inline ncGrabCancelEvent(grab::NcGrab) =
    ccall((:ncGrabCancelEvent, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabSetSerialTimeout(NcGrab grab, int serialTimeout);
@inline ncGrabSetSerialTimeout(grab::NcGrab, serialTimeout::Cint) =
    ccall((:ncGrabSetSerialTimeout, libnuvu), Status,
          (NcGrab, Cint),
          grab, serialTimeout)

# int ncGrabGetSerialTimeout(NcGrab grab, int *serialTimeout);
@inline ncGrabGetSerialTimeout(grab::NcGrab, serialTimeout::Ptr{Cint}) =
    ccall((:ncGrabGetSerialTimeout, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, serialTimeout)

# int ncGrabSetBaudrate(NcGrab grab, int baudrateSpeed);
@inline ncGrabSetBaudrate(grab::NcGrab, baudrateSpeed::Cint) =
    ccall((:ncGrabSetBaudrate, libnuvu), Status,
          (NcGrab, Cint),
          grab, baudrateSpeed)

# int ncGrabSendSerialBinaryComm(NcGrab grab, const char *command, int length);
@inline ncGrabSendSerialBinaryComm(grab::NcGrab, command::Ptr{Cchar}, length::Cint) =
    ccall((:ncGrabSendSerialBinaryComm, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Cint),
          grab, command, length)

# int ncGrabWaitSerialCmd(NcGrab grab, int length, int* numByte);
@inline ncGrabWaitSerialCmd(grab::NcGrab, length::Cint, numByte::Ptr{Cint}) =
    ccall((:ncGrabWaitSerialCmd, libnuvu), Status,
          (NcGrab, Cint, Ptr{Cint}),
          grab, length, numByte)

# int ncGrabRecSerial(NcGrab grab, char *recBuffer, int length, int* numByte);
@inline ncGrabRecSerial(grab::NcGrab, recBuffer::Ptr{Cchar}, length::Cint, numByte::Ptr{Cint}) =
    ccall((:ncGrabRecSerial, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Cint, Ptr{Cint}),
          grab, recBuffer, length, numByte)

# int ncGrabGetSerialUnreadBytes(NcGrab grab, int* numByte);
@inline ncGrabGetSerialUnreadBytes(grab::NcGrab, numByte::Ptr{Cint}) =
    ccall((:ncGrabGetSerialUnreadBytes, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, numByte)

# int ncGrabNbrImagesAcquired(NcGrab grab, int *nbrImages);
@inline ncGrabNbrImagesAcquired(grab::NcGrab, nbrImages::Ptr{Cint}) =
    ccall((:ncGrabNbrImagesAcquired, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, nbrImages)

# int ncGrabGetVersion(NcGrab grab, enum VersionType versionType, char * version, int bufferSize);
@inline ncGrabGetVersion(grab::NcGrab, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
    ccall((:ncGrabGetVersion, libnuvu), Status,
          (NcGrab, VersionType, Ptr{Cchar}, Cint),
          grab, versionType, version, bufferSize)

# int ncGrabCreateBias(NcGrab grab, int nbrImages);
@inline ncGrabCreateBias(grab::NcGrab, nbrImages::Cint) =
    ccall((:ncGrabCreateBias, libnuvu), Status,
          (NcGrab, Cint),
          grab, nbrImages)

# int ncGrabCancelBiasCreation(NcGrab grab);
@inline ncGrabCancelBiasCreation(grab::NcGrab) =
    ccall((:ncGrabCancelBiasCreation, libnuvu), Status,
          (NcGrab, ),
          grab)

# int ncGrabSetProcType(NcGrab grab, int type, int nbrImagesPc);
@inline ncGrabSetProcType(grab::NcGrab, _type::Cint, nbrImagesPc::Cint) =
    ccall((:ncGrabSetProcType, libnuvu), Status,
          (NcGrab, Cint, Cint),
          grab, _type, nbrImagesPc)

# int ncGrabGetProcType(NcGrab grab, int * type, int * nbrImagesPc);
@inline ncGrabGetProcType(grab::NcGrab, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
    ccall((:ncGrabGetProcType, libnuvu), Status,
          (NcGrab, Ptr{Cint}, Ptr{Cint}),
          grab, _type, nbrImagesPc)

# int ncGrabCreateBiasNewImageCallback(NcGrab grab, void (*fct)(NcGrab grab, int imageNo, void *data), void *data);
@inline ncGrabCreateBiasNewImageCallback(grab::NcGrab, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabCreateBiasNewImageCallback, libnuvu), Status,
          (NcGrab, Ptr{VoidCallback}, Ptr{Void}),
          grab, fct, data)

# int ncGrabStatsAddRegion(NcGrab grab, int regionWidth, int regionHeight, int *regionIndex);
@inline ncGrabStatsAddRegion(grab::NcGrab, regionWidth::Cint, regionHeight::Cint, regionIndex::Ptr{Cint}) =
    ccall((:ncGrabStatsAddRegion, libnuvu), Status,
          (NcGrab, Cint, Cint, Ptr{Cint}),
          grab, regionWidth, regionHeight, regionIndex)

# int ncGrabStatsRemoveRegion(NcGrab grab, int regionIndex);
@inline ncGrabStatsRemoveRegion(grab::NcGrab, regionIndex::Cint) =
    ccall((:ncGrabStatsRemoveRegion, libnuvu), Status,
          (NcGrab, Cint),
          grab, regionIndex)

# int ncGrabStatsResizeRegion(NcGrab grab, int regionIndex, int regionWidth, int regionHeight);
@inline ncGrabStatsResizeRegion(grab::NcGrab, regionIndex::Cint, regionWidth::Cint, regionHeight::Cint) =
    ccall((:ncGrabStatsResizeRegion, libnuvu), Status,
          (NcGrab, Cint, Cint, Cint),
          grab, regionIndex, regionWidth, regionHeight)

# int ncGrabStatsGetCrossSection(NcGrab grab, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
@inline ncGrabStatsGetCrossSection(grab::NcGrab, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, statsCtxRegion::Ptr{Cdouble}, histo::Ptr{Ptr{Cdouble}}, crossSectionHorizontal::Ptr{Ptr{Cdouble}}, crossSectionVertical::Ptr{Ptr{Cdouble}}) =
    ccall((:ncGrabStatsGetCrossSection, libnuvu), Status,
          (NcGrab, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
          grab, regionIndex, image, xCoord, yCoord, statsCtxRegion, histo, crossSectionHorizontal, crossSectionVertical)

# int ncGrabStatsGetGaussFit(NcGrab grab, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSection);
@inline ncGrabStatsGetGaussFit(grab::NcGrab, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, maxAmplitude::Ptr{Cdouble}, gaussSumHorizontal::Ptr{Cdouble}, gaussSumVertical::Ptr{Cdouble}, useActualCrossSection::Cint) =
    ccall((:ncGrabStatsGetGaussFit, libnuvu), Status,
          (NcGrab, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
          grab, regionIndex, image, xCoord, yCoord, maxAmplitude, gaussSumHorizontal, gaussSumVertical, useActualCrossSection)

# int ncCamSetOpenMacAdress(char* macAddress);
@inline ncCamSetOpenMacAdress(macAddress::Ptr{Cchar}) =
    ccall((:ncCamSetOpenMacAdress, libnuvu), Status,
          (Ptr{Cchar}, ),
          macAddress)

# int ncCamOpen(int unit, int channel, int nbrBuffer, NcCam* cam);
@inline ncCamOpen(unit::Cint, channel::Cint, nbrBuffer::Cint, cam::Ptr{NcCam}) =
    ccall((:ncCamOpen, libnuvu), Status,
          (Cint, Cint, Cint, Ptr{NcCam}),
          unit, channel, nbrBuffer, cam)

# int ncCamOpenFromList(const NcCtrlList ctrlList, int index, int nbrBuffer, NcCam* cam);
@inline ncCamOpenFromList(ctrlList::NcCtrlList, index::Cint, nbrBuffer::Cint, cam::Ptr{NcCam}) =
    ccall((:ncCamOpenFromList, libnuvu), Status,
          (NcCtrlList, Cint, Cint, Ptr{NcCam}),
          ctrlList, index, nbrBuffer, cam)

# int ncCamClose(NcCam cam);
@inline ncCamClose(cam::NcCam) =
    ccall((:ncCamClose, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamReadyToClose(NcCam cam, void (*fct)(NcCam cam, void *data), void *data);
@inline ncCamReadyToClose(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamReadyToClose, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSetHeartbeat(NcCam cam, int timeMs);
@inline ncCamSetHeartbeat(cam::NcCam, timeMs::Cint) =
    ccall((:ncCamSetHeartbeat, libnuvu), Status,
          (NcCam, Cint),
          cam, timeMs)

# int ncCamGetHeartbeat(NcCam cam, int *timeMs);
@inline ncCamGetHeartbeat(cam::NcCam, timeMs::Ptr{Cint}) =
    ccall((:ncCamGetHeartbeat, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, timeMs)

# int ncCamStart(NcCam cam, int nbrImages);
@inline ncCamStart(cam::NcCam, nbrImages::Cint) =
    ccall((:ncCamStart, libnuvu), Status,
          (NcCam, Cint),
          cam, nbrImages)

# int ncCamPrepareAcquisition(NcCam cam, int nbrImages);
@inline ncCamPrepareAcquisition(cam::NcCam, nbrImages::Cint) =
    ccall((:ncCamPrepareAcquisition, libnuvu), Status,
          (NcCam, Cint),
          cam, nbrImages)

# int ncCamBeginAcquisition(NcCam cam);
@inline ncCamBeginAcquisition(cam::NcCam) =
    ccall((:ncCamBeginAcquisition, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamAbort(NcCam cam);
@inline ncCamAbort(cam::NcCam) =
    ccall((:ncCamAbort, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncSaveImage(int width, int height, ImageParams imageParams, const void* imageNc, enum ImageDataType dataType, const char* saveName, enum ImageFormat saveFormat, enum ImageCompression compress, const char* addComments, int overwriteFlag);
@inline ncSaveImage(width::Cint, height::Cint, imageParams::ImageParams, imageNc::Ptr{Void}, dataType::ImageDataType, saveName::Ptr{Cchar}, saveFormat::ImageFormat, compress::ImageCompression, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncSaveImage, libnuvu), Status,
          (Cint, Cint, ImageParams, Ptr{Void}, ImageDataType, Ptr{Cchar}, ImageFormat, ImageCompression, Ptr{Cchar}, Cint),
          width, height, imageParams, imageNc, dataType, saveName, saveFormat, compress, addComments, overwriteFlag)

# int ncCamOpenImageParams(ImageParams *imageParams);
@inline ncCamOpenImageParams(imageParams::Ptr{ImageParams}) =
    ccall((:ncCamOpenImageParams, libnuvu), Status,
          (Ptr{ImageParams}, ),
          imageParams)

# int ncCamGetImageParams(NcCam cam, void* imageNc, ImageParams imageParams);
@inline ncCamGetImageParams(cam::NcCam, imageNc::Ptr{Void}, imageParams::ImageParams) =
    ccall((:ncCamGetImageParams, libnuvu), Status,
          (NcCam, Ptr{Void}, ImageParams),
          cam, imageNc, imageParams)

# int ncCamCloseImageParams(ImageParams imageParams);
@inline ncCamCloseImageParams(imageParams::ImageParams) =
    ccall((:ncCamCloseImageParams, libnuvu), Status,
          (ImageParams, ),
          imageParams)

# int ncCamRead(NcCam cam, NcImage** imageAcqu);
@inline ncCamRead(cam::NcCam, imageAcqu::Ptr{Ptr{NcImage}}) =
    ccall((:ncCamRead, libnuvu), Status,
          (NcCam, Ptr{Ptr{NcImage}}),
          cam, imageAcqu)

# int ncCamReadUInt32(NcCam cam, uint32_t *image);
@inline ncCamReadUInt32(cam::NcCam, image::Ptr{UInt32}) =
    ccall((:ncCamReadUInt32, libnuvu), Status,
          (NcCam, Ptr{UInt32}),
          cam, image)

# int ncCamReadFloat(NcCam cam, float *image);
@inline ncCamReadFloat(cam::NcCam, image::Ptr{Cfloat}) =
    ccall((:ncCamReadFloat, libnuvu), Status,
          (NcCam, Ptr{Cfloat}),
          cam, image)

# int ncCamReadChronological(NcCam cam, NcImage** imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadChronological(cam::NcCam, imageAcqu::Ptr{Ptr{NcImage}}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadChronological, libnuvu), Status,
          (NcCam, Ptr{Ptr{NcImage}}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamReadUInt32Chronological(NcCam cam, uint32_t* imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadUInt32Chronological(cam::NcCam, imageAcqu::Ptr{UInt32}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadUInt32Chronological, libnuvu), Status,
          (NcCam, Ptr{UInt32}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamReadFloatChronological(NcCam cam, float* imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadFloatChronological(cam::NcCam, imageAcqu::Ptr{Cfloat}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadFloatChronological, libnuvu), Status,
          (NcCam, Ptr{Cfloat}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamReadChronologicalNonBlocking(NcCam cam, NcImage **imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadChronologicalNonBlocking(cam::NcCam, imageAcqu::Ptr{Ptr{NcImage}}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadChronologicalNonBlocking, libnuvu), Status,
          (NcCam, Ptr{Ptr{NcImage}}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamReadUInt32ChronologicalNonBlocking(NcCam cam, uint32_t* imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadUInt32ChronologicalNonBlocking(cam::NcCam, imageAcqu::Ptr{UInt32}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadUInt32ChronologicalNonBlocking, libnuvu), Status,
          (NcCam, Ptr{UInt32}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamReadFloatChronologicalNonBlocking(NcCam cam, float* imageAcqu, int* nbrImagesSkipped);
@inline ncCamReadFloatChronologicalNonBlocking(cam::NcCam, imageAcqu::Ptr{Cfloat}, nbrImagesSkipped::Ptr{Cint}) =
    ccall((:ncCamReadFloatChronologicalNonBlocking, libnuvu), Status,
          (NcCam, Ptr{Cfloat}, Ptr{Cint}),
          cam, imageAcqu, nbrImagesSkipped)

# int ncCamAllocUInt32Image(NcCam cam, uint32_t **image);
@inline ncCamAllocUInt32Image(cam::NcCam, image::Ptr{Ptr{UInt32}}) =
    ccall((:ncCamAllocUInt32Image, libnuvu), Status,
          (NcCam, Ptr{Ptr{UInt32}}),
          cam, image)

# int ncCamFreeUInt32Image(uint32_t **image);
@inline ncCamFreeUInt32Image(image::Ptr{Ptr{UInt32}}) =
    ccall((:ncCamFreeUInt32Image, libnuvu), Status,
          (Ptr{Ptr{UInt32}}, ),
          image)

# int ncCamFlushReadQueues(NcCam cam);
@inline ncCamFlushReadQueues(cam::NcCam) =
    ccall((:ncCamFlushReadQueues, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamGetOverrun(NcCam cam, int* overrunOccurred);
@inline ncCamGetOverrun(cam::NcCam, overrunOccurred::Ptr{Cint}) =
    ccall((:ncCamGetOverrun, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, overrunOccurred)

# int ncCamGetNbrDroppedImages(NcCam cam, int* nbrDroppedImages);
@inline ncCamGetNbrDroppedImages(cam::NcCam, nbrDroppedImages::Ptr{Cint}) =
    ccall((:ncCamGetNbrDroppedImages, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, nbrDroppedImages)

# int ncCamGetNbrTimeout(NcCam cam, int* nbrTimeout);
@inline ncCamGetNbrTimeout(cam::NcCam, nbrTimeout::Ptr{Cint}) =
    ccall((:ncCamGetNbrTimeout, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, nbrTimeout)

# int ncCamSetTimeout(NcCam cam, int timeMs);
@inline ncCamSetTimeout(cam::NcCam, timeMs::Cint) =
    ccall((:ncCamSetTimeout, libnuvu), Status,
          (NcCam, Cint),
          cam, timeMs)

# int ncCamGetTimeout(NcCam cam, int* timeTimeout);
@inline ncCamGetTimeout(cam::NcCam, timeTimeout::Ptr{Cint}) =
    ccall((:ncCamGetTimeout, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, timeTimeout)

# int ncCamGetSize(NcCam cam, int *width, int *height);
@inline ncCamGetSize(cam::NcCam, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetSize, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, width, height)

# int ncCamGetMaxSize(NcCam cam, int *width, int *height);
@inline ncCamGetMaxSize(cam::NcCam, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetMaxSize, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, width, height)

# int ncCamGetOverscanLines(NcCam cam, int *overscanLines);
@inline ncCamGetOverscanLines(cam::NcCam, overscanLines::Ptr{Cint}) =
    ccall((:ncCamGetOverscanLines, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, overscanLines)

# int ncCamGetFrameLatency(NcCam cam, int *frameLatency);
@inline ncCamGetFrameLatency(cam::NcCam, frameLatency::Ptr{Cint}) =
    ccall((:ncCamGetFrameLatency, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, frameLatency)

# int ncCamSaveImage(NcCam cam, const NcImage* imageNc, const char* saveName, enum ImageFormat saveFormat, const char* addComments, int overwriteFlag);
@inline ncCamSaveImage(cam::NcCam, imageNc::Ptr{NcImage}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncCamSaveImage, libnuvu), Status,
          (NcCam, Ptr{NcImage}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
          cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

# int ncCamSaveUInt32Image(NcCam cam, const uint32_t *imageNc, const char *saveName, enum ImageFormat saveFormat, const char *addComments, int overwriteFlag);
@inline ncCamSaveUInt32Image(cam::NcCam, imageNc::Ptr{UInt32}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncCamSaveUInt32Image, libnuvu), Status,
          (NcCam, Ptr{UInt32}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
          cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

# int ncCamSaveFloatImage(NcCam cam, const float *imageNc, const char *saveName, enum ImageFormat saveFormat, const char *addComments, int overwriteFlag);
@inline ncCamSaveFloatImage(cam::NcCam, imageNc::Ptr{Cfloat}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncCamSaveFloatImage, libnuvu), Status,
          (NcCam, Ptr{Cfloat}, Ptr{Cchar}, ImageFormat, Ptr{Cchar}, Cint),
          cam, imageNc, saveName, saveFormat, addComments, overwriteFlag)

# int ncCamSaveImageEx(NcCam cam, const void * imageNc, const char* saveName, enum ImageFormat saveFormat, enum ImageDataType dataFormat, const char* addComments, int overwriteFlag);
@inline ncCamSaveImageEx(cam::NcCam, imageNc::Ptr{Void}, saveName::Ptr{Cchar}, saveFormat::ImageFormat, dataFormat::ImageDataType, addComments::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncCamSaveImageEx, libnuvu), Status,
          (NcCam, Ptr{Void}, Ptr{Cchar}, ImageFormat, ImageDataType, Ptr{Cchar}, Cint),
          cam, imageNc, saveName, saveFormat, dataFormat, addComments, overwriteFlag)

# int ncCamStartSaveAcquisition(NcCam cam, const char *saveName, enum ImageFormat saveFormat, int imagesPerCubes, const char *addComments, int nbrOfCubes, int overwriteFlag);
@inline ncCamStartSaveAcquisition(cam::NcCam, saveName::Ptr{Cchar}, saveFormat::ImageFormat, imagesPerCubes::Cint, addComments::Ptr{Cchar}, nbrOfCubes::Cint, overwriteFlag::Cint) =
    ccall((:ncCamStartSaveAcquisition, libnuvu), Status,
          (NcCam, Ptr{Cchar}, ImageFormat, Cint, Ptr{Cchar}, Cint, Cint),
          cam, saveName, saveFormat, imagesPerCubes, addComments, nbrOfCubes, overwriteFlag)

# int ncCamStopSaveAcquisition(NcCam cam);
@inline ncCamStopSaveAcquisition(cam::NcCam) =
    ccall((:ncCamStopSaveAcquisition, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamSaveImageSetHeaderCallback(NcCam cam, void (*fct)(NcCam cam, NcImageSaved *imageFile, void *data), void *data);
@inline ncCamSaveImageSetHeaderCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSaveImageSetHeaderCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSaveImageWriteCallback(NcCam cam, void (*fct)(NcCam cam, int imageNo, void *data), void *data);
@inline ncCamSaveImageWriteCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSaveImageWriteCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSaveImageCloseCallback(NcCam cam, void (*fct)(NcCam cam, int fileNo, void *data), void *data);
@inline ncCamSaveImageCloseCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSaveImageCloseCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSaveImageSetCompressionType(NcCam cam, enum ImageCompression compress);
@inline ncCamSaveImageSetCompressionType(cam::NcCam, compress::ImageCompression) =
    ccall((:ncCamSaveImageSetCompressionType, libnuvu), Status,
          (NcCam, ImageCompression),
          cam, compress)

# int ncCamSaveImageGetCompressionType(NcCam cam, enum ImageCompression *compress);
@inline ncCamSaveImageGetCompressionType(cam::NcCam, compress::Ptr{ImageCompression}) =
    ccall((:ncCamSaveImageGetCompressionType, libnuvu), Status,
          (NcCam, Ptr{ImageCompression}),
          cam, compress)

# int ncCamResetTimer(NcCam cam, double timeOffset);
@inline ncCamResetTimer(cam::NcCam, timeOffset::Cdouble) =
    ccall((:ncCamResetTimer, libnuvu), Status,
          (NcCam, Cdouble),
          cam, timeOffset)

# int ncCamSetEvent(NcCam cam, NcCallbackFunc funcName, void *ncData);
@inline ncCamSetEvent(cam::NcCam, funcName::NcCallbackFunc, ncData::Ptr{Void}) =
    ccall((:ncCamSetEvent, libnuvu), Status,
          (NcCam, NcCallbackFunc, Ptr{Void}),
          cam, funcName, ncData)

# int ncCamCancelEvent(NcCam cam);
@inline ncCamCancelEvent(cam::NcCam) =
    ccall((:ncCamCancelEvent, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamSetTimestampMode(NcCam cam, enum TimestampMode timestampMode);
@inline ncCamSetTimestampMode(cam::NcCam, timestampMode::TimestampMode) =
    ccall((:ncCamSetTimestampMode, libnuvu), Status,
          (NcCam, TimestampMode),
          cam, timestampMode)

# int ncCamGetTimestampMode(NcCam cam, int cameraRequest, enum TimestampMode *timestampMode, int *gpsSignalValid);
@inline ncCamGetTimestampMode(cam::NcCam, cameraRequest::Cint, timestampMode::Ptr{TimestampMode}, gpsSignalValid::Ptr{Cint}) =
    ccall((:ncCamGetTimestampMode, libnuvu), Status,
          (NcCam, Cint, Ptr{TimestampMode}, Ptr{Cint}),
          cam, cameraRequest, timestampMode, gpsSignalValid)

# int ncCamSetTimestampInternal(NcCam cam, struct tm *dateTime, int nbrUs);
@inline ncCamSetTimestampInternal(cam::NcCam, dateTime::Ptr{TmStruct}, nbrUs::Cint) =
    ccall((:ncCamSetTimestampInternal, libnuvu), Status,
          (NcCam, Ptr{TmStruct}, Cint),
          cam, dateTime, nbrUs)

# int ncCamGetCtrlTimestamp(NcCam cam, NcImage* imageAcqu, struct tm *ctrTimestamp, double *ctrlSecondFraction, int *status);
@inline ncCamGetCtrlTimestamp(cam::NcCam, imageAcqu::Ptr{NcImage}, ctrTimestamp::Ptr{TmStruct}, ctrlSecondFraction::Ptr{Cdouble}, status::Ptr{Cint}) =
    ccall((:ncCamGetCtrlTimestamp, libnuvu), Status,
          (NcCam, Ptr{NcImage}, Ptr{TmStruct}, Ptr{Cdouble}, Ptr{Cint}),
          cam, imageAcqu, ctrTimestamp, ctrlSecondFraction, status)

# int ncCamGetHostSystemTimestamp(NcCam cam, NcImage* imageAcqu, double *hostSystemTimestamp);
@inline ncCamGetHostSystemTimestamp(cam::NcCam, imageAcqu::Ptr{NcImage}, hostSystemTimestamp::Ptr{Cdouble}) =
    ccall((:ncCamGetHostSystemTimestamp, libnuvu), Status,
          (NcCam, Ptr{NcImage}, Ptr{Cdouble}),
          cam, imageAcqu, hostSystemTimestamp)

# int ncCamParamAvailable(NcCam cam, enum Features param, int setting);
@inline ncCamParamAvailable(cam::NcCam, param::Features, setting::Cint) =
    ccall((:ncCamParamAvailable, libnuvu), Status,
          (NcCam, Features, Cint),
          cam, param, setting)

# int ncCamSaveParam(NcCam cam, const char* saveName, int overwriteFlag);
@inline ncCamSaveParam(cam::NcCam, saveName::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncCamSaveParam, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Cint),
          cam, saveName, overwriteFlag)

# int ncCamLoadParam(NcCam cam, const char* saveName);
@inline ncCamLoadParam(cam::NcCam, saveName::Ptr{Cchar}) =
    ccall((:ncCamLoadParam, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, saveName)

# int ncCamSaveParamSetHeaderCallback(NcCam cam, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncCamSaveParamSetHeaderCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSaveParamSetHeaderCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamLoadParamSetHeaderCallback(NcCam cam, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncCamLoadParamSetHeaderCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamLoadParamSetHeaderCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSetReadoutMode(NcCam cam, int value);
@inline ncCamSetReadoutMode(cam::NcCam, value::Cint) =
    ccall((:ncCamSetReadoutMode, libnuvu), Status,
          (NcCam, Cint),
          cam, value)

# int ncCamGetCurrentReadoutMode(NcCam cam, int* readoutMode, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
@inline ncCamGetCurrentReadoutMode(cam::NcCam, readoutMode::Ptr{Cint}, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
    ccall((:ncCamGetCurrentReadoutMode, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
          cam, readoutMode, ampliType, ampliString, vertFreq, horizFreq)

# int ncCamGetReadoutMode(NcCam cam, int number, enum Ampli* ampliType, char* ampliString, int *vertFreq, int *horizFreq);
@inline ncCamGetReadoutMode(cam::NcCam, number::Cint, ampliType::Ptr{Ampli}, ampliString::Ptr{Cchar}, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}) =
    ccall((:ncCamGetReadoutMode, libnuvu), Status,
          (NcCam, Cint, Ptr{Ampli}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}),
          cam, number, ampliType, ampliString, vertFreq, horizFreq)

# int ncCamGetNbrReadoutModes(NcCam cam, int* nbrReadoutMode);
@inline ncCamGetNbrReadoutModes(cam::NcCam, nbrReadoutMode::Ptr{Cint}) =
    ccall((:ncCamGetNbrReadoutModes, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, nbrReadoutMode)

# int ncCamGetReadoutTime(NcCam cam, double *time);
@inline ncCamGetReadoutTime(cam::NcCam, time::Ptr{Cdouble}) =
    ccall((:ncCamGetReadoutTime, libnuvu), Status,
          (NcCam, Ptr{Cdouble}),
          cam, time)

# int ncCamGetAmpliTypeAvail(NcCam cam, enum Ampli ampli, int *number);
@inline ncCamGetAmpliTypeAvail(cam::NcCam, ampli::Ampli, number::Ptr{Cint}) =
    ccall((:ncCamGetAmpliTypeAvail, libnuvu), Status,
          (NcCam, Ampli, Ptr{Cint}),
          cam, ampli, number)

# int ncCamGetFreqAvail(NcCam cam, enum Ampli ampli, int ampliNo, int *vertFreq, int *horizFreq, int* readoutModeNo);
@inline ncCamGetFreqAvail(cam::NcCam, ampli::Ampli, ampliNo::Cint, vertFreq::Ptr{Cint}, horizFreq::Ptr{Cint}, readoutModeNo::Ptr{Cint}) =
    ccall((:ncCamGetFreqAvail, libnuvu), Status,
          (NcCam, Ampli, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          cam, ampli, ampliNo, vertFreq, horizFreq, readoutModeNo)

# int ncCamSetExposureTime(NcCam cam, double exposureTime);
@inline ncCamSetExposureTime(cam::NcCam, exposureTime::Cdouble) =
    ccall((:ncCamSetExposureTime, libnuvu), Status,
          (NcCam, Cdouble),
          cam, exposureTime)

# int ncCamGetExposureTime(NcCam cam, int cameraRequest, double* exposureTime);
@inline ncCamGetExposureTime(cam::NcCam, cameraRequest::Cint, exposureTime::Ptr{Cdouble}) =
    ccall((:ncCamGetExposureTime, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, exposureTime)

# int ncCamSetWaitingTime(NcCam cam, double waitingTime);
@inline ncCamSetWaitingTime(cam::NcCam, waitingTime::Cdouble) =
    ccall((:ncCamSetWaitingTime, libnuvu), Status,
          (NcCam, Cdouble),
          cam, waitingTime)

# int ncCamGetWaitingTime(NcCam cam, int cameraRequest, double* waitingTime);
@inline ncCamGetWaitingTime(cam::NcCam, cameraRequest::Cint, waitingTime::Ptr{Cdouble}) =
    ccall((:ncCamGetWaitingTime, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, waitingTime)

# int ncCamSetTriggerMode(NcCam cam, enum TriggerMode triggerMode, int nbrImages);
@inline ncCamSetTriggerMode(cam::NcCam, triggerMode::TriggerMode, nbrImages::Cint) =
    ccall((:ncCamSetTriggerMode, libnuvu), Status,
          (NcCam, TriggerMode, Cint),
          cam, triggerMode, nbrImages)

# int ncCamGetTriggerMode(NcCam cam, int cameraRequest, enum TriggerMode* triggerMode, int* nbrImagesPerTrig);
@inline ncCamGetTriggerMode(cam::NcCam, cameraRequest::Cint, triggerMode::Ptr{TriggerMode}, nbrImagesPerTrig::Ptr{Cint}) =
    ccall((:ncCamGetTriggerMode, libnuvu), Status,
          (NcCam, Cint, Ptr{TriggerMode}, Ptr{Cint}),
          cam, cameraRequest, triggerMode, nbrImagesPerTrig)

# int ncCamSetShutterMode(NcCam cam, enum ShutterMode shutterMode);
@inline ncCamSetShutterMode(cam::NcCam, shutterMode::ShutterMode) =
    ccall((:ncCamSetShutterMode, libnuvu), Status,
          (NcCam, ShutterMode),
          cam, shutterMode)

# int ncCamGetShutterMode(NcCam cam, int cameraRequest, enum ShutterMode* shutterMode);
@inline ncCamGetShutterMode(cam::NcCam, cameraRequest::Cint, shutterMode::Ptr{ShutterMode}) =
    ccall((:ncCamGetShutterMode, libnuvu), Status,
          (NcCam, Cint, Ptr{ShutterMode}),
          cam, cameraRequest, shutterMode)

# int ncCamSetShutterPolarity(NcCam cam, enum ExtPolarity shutterPolarity);
@inline ncCamSetShutterPolarity(cam::NcCam, shutterPolarity::ExtPolarity) =
    ccall((:ncCamSetShutterPolarity, libnuvu), Status,
          (NcCam, ExtPolarity),
          cam, shutterPolarity)

# int ncCamGetShutterPolarity(NcCam cam, int cameraRequest, enum ExtPolarity* shutterPolarity);
@inline ncCamGetShutterPolarity(cam::NcCam, cameraRequest::Cint, shutterPolarity::Ptr{ExtPolarity}) =
    ccall((:ncCamGetShutterPolarity, libnuvu), Status,
          (NcCam, Cint, Ptr{ExtPolarity}),
          cam, cameraRequest, shutterPolarity)

# int ncCamSetExternalShutter(NcCam cam, enum ExtShutter externalShutterPresence);
@inline ncCamSetExternalShutter(cam::NcCam, externalShutterPresence::ExtShutter) =
    ccall((:ncCamSetExternalShutter, libnuvu), Status,
          (NcCam, ExtShutter),
          cam, externalShutterPresence)

# int ncCamGetExternalShutter(NcCam cam, int cameraRequest, enum ExtShutter* externalShutterPresence);
@inline ncCamGetExternalShutter(cam::NcCam, cameraRequest::Cint, externalShutterPresence::Ptr{ExtShutter}) =
    ccall((:ncCamGetExternalShutter, libnuvu), Status,
          (NcCam, Cint, Ptr{ExtShutter}),
          cam, cameraRequest, externalShutterPresence)

# int ncCamSetExternalShutterMode(NcCam cam, enum ShutterMode externalShutterMode);
@inline ncCamSetExternalShutterMode(cam::NcCam, externalShutterMode::ShutterMode) =
    ccall((:ncCamSetExternalShutterMode, libnuvu), Status,
          (NcCam, ShutterMode),
          cam, externalShutterMode)

# int ncCamGetExternalShutterMode(NcCam cam, int cameraRequest, enum ShutterMode* externalShutterMode);
@inline ncCamGetExternalShutterMode(cam::NcCam, cameraRequest::Cint, externalShutterMode::Ptr{ShutterMode}) =
    ccall((:ncCamGetExternalShutterMode, libnuvu), Status,
          (NcCam, Cint, Ptr{ShutterMode}),
          cam, cameraRequest, externalShutterMode)

# int ncCamSetExternalShutterDelay(NcCam cam, double externalShutterDelay);
@inline ncCamSetExternalShutterDelay(cam::NcCam, externalShutterDelay::Cdouble) =
    ccall((:ncCamSetExternalShutterDelay, libnuvu), Status,
          (NcCam, Cdouble),
          cam, externalShutterDelay)

# int ncCamGetExternalShutterDelay(NcCam cam, int cameraRequest, double* externalShutterDelay);
@inline ncCamGetExternalShutterDelay(cam::NcCam, cameraRequest::Cint, externalShutterDelay::Ptr{Cdouble}) =
    ccall((:ncCamGetExternalShutterDelay, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, externalShutterDelay)

# int ncCamSetFirePolarity(NcCam cam, enum ExtPolarity firePolarity);
@inline ncCamSetFirePolarity(cam::NcCam, firePolarity::ExtPolarity) =
    ccall((:ncCamSetFirePolarity, libnuvu), Status,
          (NcCam, ExtPolarity),
          cam, firePolarity)

# int ncCamGetFirePolarity(NcCam cam, int cameraRequest, enum ExtPolarity* firePolarity);
@inline ncCamGetFirePolarity(cam::NcCam, cameraRequest::Cint, firePolarity::Ptr{ExtPolarity}) =
    ccall((:ncCamGetFirePolarity, libnuvu), Status,
          (NcCam, Cint, Ptr{ExtPolarity}),
          cam, cameraRequest, firePolarity)

# int ncCamSetOutputMinimumPulseWidth(NcCam cam, double outputPulseWidth);
@inline ncCamSetOutputMinimumPulseWidth(cam::NcCam, outputPulseWidth::Cdouble) =
    ccall((:ncCamSetOutputMinimumPulseWidth, libnuvu), Status,
          (NcCam, Cdouble),
          cam, outputPulseWidth)

# int ncCamGetOutputMinimumPulseWidth(NcCam cam, int cameraRequest, double *outputPulseWidth);
@inline ncCamGetOutputMinimumPulseWidth(cam::NcCam, cameraRequest::Cint, outputPulseWidth::Ptr{Cdouble}) =
    ccall((:ncCamGetOutputMinimumPulseWidth, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, outputPulseWidth)

# int ncCamSetArmPolarity(NcCam cam, enum ExtPolarity armPolarity);
@inline ncCamSetArmPolarity(cam::NcCam, armPolarity::ExtPolarity) =
    ccall((:ncCamSetArmPolarity, libnuvu), Status,
          (NcCam, ExtPolarity),
          cam, armPolarity)

# int ncCamGetArmPolarity(NcCam cam, int cameraRequest, enum ExtPolarity* armPolarity);
@inline ncCamGetArmPolarity(cam::NcCam, cameraRequest::Cint, armPolarity::Ptr{ExtPolarity}) =
    ccall((:ncCamGetArmPolarity, libnuvu), Status,
          (NcCam, Cint, Ptr{ExtPolarity}),
          cam, cameraRequest, armPolarity)

# int ncCamSetCalibratedEmGain(NcCam cam, int calibratedEmGain);
@inline ncCamSetCalibratedEmGain(cam::NcCam, calibratedEmGain::Cint) =
    ccall((:ncCamSetCalibratedEmGain, libnuvu), Status,
          (NcCam, Cint),
          cam, calibratedEmGain)

# int ncCamGetCalibratedEmGain(NcCam cam, int cameraRequest, int *calibratedEmGain);
@inline ncCamGetCalibratedEmGain(cam::NcCam, cameraRequest::Cint, calibratedEmGain::Ptr{Cint}) =
    ccall((:ncCamGetCalibratedEmGain, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}),
          cam, cameraRequest, calibratedEmGain)

# int ncCamGetCalibratedEmGainRange(NcCam cam, int* calibratedEmGainMin, int* calibratedEmGainMax);
@inline ncCamGetCalibratedEmGainRange(cam::NcCam, calibratedEmGainMin::Ptr{Cint}, calibratedEmGainMax::Ptr{Cint}) =
    ccall((:ncCamGetCalibratedEmGainRange, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, calibratedEmGainMin, calibratedEmGainMax)

# int ncCamGetCalibratedEmGainTempRange(NcCam cam, double* calibratedEmGainTempMin, double* calibratedEmGainTempMax);
@inline ncCamGetCalibratedEmGainTempRange(cam::NcCam, calibratedEmGainTempMin::Ptr{Cdouble}, calibratedEmGainTempMax::Ptr{Cdouble}) =
    ccall((:ncCamGetCalibratedEmGainTempRange, libnuvu), Status,
          (NcCam, Ptr{Cdouble}, Ptr{Cdouble}),
          cam, calibratedEmGainTempMin, calibratedEmGainTempMax)

# int ncCamSetRawEmGain(NcCam cam, int rawEmGain);
@inline ncCamSetRawEmGain(cam::NcCam, rawEmGain::Cint) =
    ccall((:ncCamSetRawEmGain, libnuvu), Status,
          (NcCam, Cint),
          cam, rawEmGain)

# int ncCamGetRawEmGain(NcCam cam, int cameraRequest, int* rawEmGain);
@inline ncCamGetRawEmGain(cam::NcCam, cameraRequest::Cint, rawEmGain::Ptr{Cint}) =
    ccall((:ncCamGetRawEmGain, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}),
          cam, cameraRequest, rawEmGain)

# int ncCamGetRawEmGainRange(NcCam cam, int* rawEmGainMin, int* rawEmGainMax);
@inline ncCamGetRawEmGainRange(cam::NcCam, rawEmGainMin::Ptr{Cint}, rawEmGainMax::Ptr{Cint}) =
    ccall((:ncCamGetRawEmGainRange, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, rawEmGainMin, rawEmGainMax)

# int ncCamSetAnalogGain(NcCam cam, int analogGain);
@inline ncCamSetAnalogGain(cam::NcCam, analogGain::Cint) =
    ccall((:ncCamSetAnalogGain, libnuvu), Status,
          (NcCam, Cint),
          cam, analogGain)

# int ncCamGetAnalogGain(NcCam cam, int cameraRequest, int* analogGain);
@inline ncCamGetAnalogGain(cam::NcCam, cameraRequest::Cint, analogGain::Ptr{Cint}) =
    ccall((:ncCamGetAnalogGain, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}),
          cam, cameraRequest, analogGain)

# int ncCamGetAnalogGainRange(NcCam cam, int* analogGainMin, int* analogGainMax);
@inline ncCamGetAnalogGainRange(cam::NcCam, analogGainMin::Ptr{Cint}, analogGainMax::Ptr{Cint}) =
    ccall((:ncCamGetAnalogGainRange, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, analogGainMin, analogGainMax)

# int ncCamSetAnalogOffset(NcCam cam, int analogOffset);
@inline ncCamSetAnalogOffset(cam::NcCam, analogOffset::Cint) =
    ccall((:ncCamSetAnalogOffset, libnuvu), Status,
          (NcCam, Cint),
          cam, analogOffset)

# int ncCamGetAnalogOffset(NcCam cam, int cameraRequest, int* analogOffset);
@inline ncCamGetAnalogOffset(cam::NcCam, cameraRequest::Cint, analogOffset::Ptr{Cint}) =
    ccall((:ncCamGetAnalogOffset, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}),
          cam, cameraRequest, analogOffset)

# int ncCamGetAnalogOffsetRange(NcCam cam, int* analogOffsetMin, int* analogOffsetMax);
@inline ncCamGetAnalogOffsetRange(cam::NcCam, analogOffsetMin::Ptr{Cint}, analogOffsetMax::Ptr{Cint}) =
    ccall((:ncCamGetAnalogOffsetRange, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, analogOffsetMin, analogOffsetMax)

# int ncCamSetTargetDetectorTemp(NcCam cam, double targetDetectorTemp);
@inline ncCamSetTargetDetectorTemp(cam::NcCam, targetDetectorTemp::Cdouble) =
    ccall((:ncCamSetTargetDetectorTemp, libnuvu), Status,
          (NcCam, Cdouble),
          cam, targetDetectorTemp)

# int ncCamGetDetectorTemp(NcCam cam, double* detectorTemp);
@inline ncCamGetDetectorTemp(cam::NcCam, detectorTemp::Ptr{Cdouble}) =
    ccall((:ncCamGetDetectorTemp, libnuvu), Status,
          (NcCam, Ptr{Cdouble}),
          cam, detectorTemp)

# int ncCamGetTargetDetectorTemp(NcCam cam, int cameraRequest, double* targetDetectorTemp);
@inline ncCamGetTargetDetectorTemp(cam::NcCam, cameraRequest::Cint, targetDetectorTemp::Ptr{Cdouble}) =
    ccall((:ncCamGetTargetDetectorTemp, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, targetDetectorTemp)

# int ncCamGetTargetDetectorTempRange(NcCam cam, double *targetDetectorTempMin, double *targetDetectorTempMax);
@inline ncCamGetTargetDetectorTempRange(cam::NcCam, targetDetectorTempMin::Ptr{Cdouble}, targetDetectorTempMax::Ptr{Cdouble}) =
    ccall((:ncCamGetTargetDetectorTempRange, libnuvu), Status,
          (NcCam, Ptr{Cdouble}, Ptr{Cdouble}),
          cam, targetDetectorTempMin, targetDetectorTempMax)

# int ncCamGetComponentTemp(NcCam cam, enum NcTemperatureType temp, double * value);
@inline ncCamGetComponentTemp(cam::NcCam, temp::NcTemperatureType, value::Ptr{Cdouble}) =
    ccall((:ncCamGetComponentTemp, libnuvu), Status,
          (NcCam, NcTemperatureType, Ptr{Cdouble}),
          cam, temp, value)

# int ncCamGetSerialNumber(NcCam cam, char *sn);
@inline ncCamGetSerialNumber(cam::NcCam, sn::Ptr{Cchar}) =
    ccall((:ncCamGetSerialNumber, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, sn)

# int ncCamGetDetectorType(NcCam cam, enum DetectorType *type);
@inline ncCamGetDetectorType(cam::NcCam, _type::Ptr{DetectorType}) =
    ccall((:ncCamGetDetectorType, libnuvu), Status,
          (NcCam, Ptr{DetectorType}),
          cam, _type)

# int ncCamDetectorTypeEnumToString(enum DetectorType detectorType, const char** str);
@inline ncCamDetectorTypeEnumToString(detectorType::DetectorType, str::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamDetectorTypeEnumToString, libnuvu), Status,
          (DetectorType, Ptr{Ptr{Cchar}}),
          detectorType, str)

# int ncCamSetBinningMode(NcCam cam, int binXValue, int binYValue);
@inline ncCamSetBinningMode(cam::NcCam, binXValue::Cint, binYValue::Cint) =
    ccall((:ncCamSetBinningMode, libnuvu), Status,
          (NcCam, Cint, Cint),
          cam, binXValue, binYValue)

# int ncCamGetBinningMode(NcCam cam, int *binXValue, int *binYValue);
@inline ncCamGetBinningMode(cam::NcCam, binXValue::Ptr{Cint}, binYValue::Ptr{Cint}) =
    ccall((:ncCamGetBinningMode, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, binXValue, binYValue)

# int ncCamSetMRoiSize(NcCam cam, int index, int width, int height);
@inline ncCamSetMRoiSize(cam::NcCam, index::Cint, width::Cint, height::Cint) =
    ccall((:ncCamSetMRoiSize, libnuvu), Status,
          (NcCam, Cint, Cint, Cint),
          cam, index, width, height)

# int ncCamGetMRoiSize(NcCam cam, int index, int * width, int * height);
@inline ncCamGetMRoiSize(cam::NcCam, index::Cint, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetMRoiSize, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}, Ptr{Cint}),
          cam, index, width, height)

# int ncCamSetMRoiPosition(NcCam cam, int index, int offsetX, int offsetY);
@inline ncCamSetMRoiPosition(cam::NcCam, index::Cint, offsetX::Cint, offsetY::Cint) =
    ccall((:ncCamSetMRoiPosition, libnuvu), Status,
          (NcCam, Cint, Cint, Cint),
          cam, index, offsetX, offsetY)

# int ncCamGetMRoiPosition(NcCam cam, int index, int * offsetX, int * offsetY);
@inline ncCamGetMRoiPosition(cam::NcCam, index::Cint, offsetX::Ptr{Cint}, offsetY::Ptr{Cint}) =
    ccall((:ncCamGetMRoiPosition, libnuvu), Status,
          (NcCam, Cint, Ptr{Cint}, Ptr{Cint}),
          cam, index, offsetX, offsetY)

# int ncCamGetMRoiCount(NcCam cam, int * count);
@inline ncCamGetMRoiCount(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamGetMRoiCount, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamGetMRoiCountMax(NcCam cam, int * count);
@inline ncCamGetMRoiCountMax(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamGetMRoiCountMax, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamAddMRoi(NcCam cam, int offsetX, int offsetY, int width, int height);
@inline ncCamAddMRoi(cam::NcCam, offsetX::Cint, offsetY::Cint, width::Cint, height::Cint) =
    ccall((:ncCamAddMRoi, libnuvu), Status,
          (NcCam, Cint, Cint, Cint, Cint),
          cam, offsetX, offsetY, width, height)

# int ncCamDeleteMRoi(NcCam cam, int index);
@inline ncCamDeleteMRoi(cam::NcCam, index::Cint) =
    ccall((:ncCamDeleteMRoi, libnuvu), Status,
          (NcCam, Cint),
          cam, index)

# int ncCamGetMRoiInputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
@inline ncCamGetMRoiInputRegion(params::ImageParams, index::Cint, offsetX::Ptr{Cint}, offsetY::Ptr{Cint}, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetMRoiInputRegion, libnuvu), Status,
          (ImageParams, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          params, index, offsetX, offsetY, width, height)

# int ncCamGetMRoiOutputRegion(ImageParams params, int index, int * offsetX, int * offsetY, int * width, int * height);
@inline ncCamGetMRoiOutputRegion(params::ImageParams, index::Cint, offsetX::Ptr{Cint}, offsetY::Ptr{Cint}, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetMRoiOutputRegion, libnuvu), Status,
          (ImageParams, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          params, index, offsetX, offsetY, width, height)

# int ncCamGetMRoiRegionCount(ImageParams params, int * count);
@inline ncCamGetMRoiRegionCount(params::ImageParams, count::Ptr{Cint}) =
    ccall((:ncCamGetMRoiRegionCount, libnuvu), Status,
          (ImageParams, Ptr{Cint}),
          params, count)

# int ncCamMRoiApply(NcCam cam);
@inline ncCamMRoiApply(cam::NcCam) =
    ccall((:ncCamMRoiApply, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamMRoiRollback(NcCam cam);
@inline ncCamMRoiRollback(cam::NcCam) =
    ccall((:ncCamMRoiRollback, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamMRoiHasChanges(NcCam cam, int * hasChanges);
@inline ncCamMRoiHasChanges(cam::NcCam, hasChanges::Ptr{Cint}) =
    ccall((:ncCamMRoiHasChanges, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, hasChanges)

# int ncCamMRoiCanApplyWithoutStop(NcCam cam, int * nonStop);
@inline ncCamMRoiCanApplyWithoutStop(cam::NcCam, nonStop::Ptr{Cint}) =
    ccall((:ncCamMRoiCanApplyWithoutStop, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, nonStop)

# int ncCamGetVersion(NcCam cam, enum VersionType versionType, char * version, int bufferSize);
@inline ncCamGetVersion(cam::NcCam, versionType::VersionType, version::Ptr{Cchar}, bufferSize::Cint) =
    ccall((:ncCamGetVersion, libnuvu), Status,
          (NcCam, VersionType, Ptr{Cchar}, Cint),
          cam, versionType, version, bufferSize)

# int ncCamGetActiveRegion(NcCam cam, int *width, int *height);
@inline ncCamGetActiveRegion(cam::NcCam, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetActiveRegion, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, width, height)

# int ncCamGetFullCCDSize(NcCam cam, int *width, int *height);
@inline ncCamGetFullCCDSize(cam::NcCam, width::Ptr{Cint}, height::Ptr{Cint}) =
    ccall((:ncCamGetFullCCDSize, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, width, height)

# int ncCamNbrImagesAcquired(NcCam cam, int *nbrImages);
@inline ncCamNbrImagesAcquired(cam::NcCam, nbrImages::Ptr{Cint}) =
    ccall((:ncCamNbrImagesAcquired, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, nbrImages)

# int ncCamGetSafeShutdownTemperature(NcCam cam, double *safeTemperature, int *dontCare);
@inline ncCamGetSafeShutdownTemperature(cam::NcCam, safeTemperature::Ptr{Cdouble}, dontCare::Ptr{Cint}) =
    ccall((:ncCamGetSafeShutdownTemperature, libnuvu), Status,
          (NcCam, Ptr{Cdouble}, Ptr{Cint}),
          cam, safeTemperature, dontCare)

# int ncCamSetCropMode( NcCam cam, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY );
@inline ncCamSetCropMode(cam::NcCam, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint) =
    ccall((:ncCamSetCropMode, libnuvu), Status,
          (NcCam, CropMode, Cint, Cint),
          cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

# int ncCamGetCropMode( NcCam cam, enum CropMode* mode, int* paddingPixelsMinimumX, int* paddingPixelsMinimumY, float* figureOfMerit);
@inline ncCamGetCropMode(cam::NcCam, mode::Ptr{CropMode}, paddingPixelsMinimumX::Ptr{Cint}, paddingPixelsMinimumY::Ptr{Cint}, figureOfMerit::Ptr{Cfloat}) =
    ccall((:ncCamGetCropMode, libnuvu), Status,
          (NcCam, Ptr{CropMode}, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}),
          cam, mode, paddingPixelsMinimumX, paddingPixelsMinimumY, figureOfMerit)

# int ncCropModeSolutionsOpen( NcCropModeSolutions* solutionSet, int cropWidth, int cropHeight, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY, NcCam cam);
@inline ncCropModeSolutionsOpen(solutionSet::Ptr{NcCropModeSolutions}, cropWidth::Cint, cropHeight::Cint, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint, cam::NcCam) =
    ccall((:ncCropModeSolutionsOpen, libnuvu), Status,
          (Ptr{NcCropModeSolutions}, Cint, Cint, CropMode, Cint, Cint, NcCam),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY, cam)

# int ncCropModeSolutionsRefresh( NcCropModeSolutions solutionSet );
@inline ncCropModeSolutionsRefresh(solutionSet::NcCropModeSolutions) =
    ccall((:ncCropModeSolutionsRefresh, libnuvu), Status,
          (NcCropModeSolutions, ),
          solutionSet)

# int ncCropModeSolutionsSetParameters( NcCropModeSolutions solutionSet, int cropWidth, int cropHeight, enum CropMode mode, int paddingPixelsMinimumX, int paddingPixelsMinimumY);
@inline ncCropModeSolutionsSetParameters(solutionSet::NcCropModeSolutions, cropWidth::Cint, cropHeight::Cint, mode::CropMode, paddingPixelsMinimumX::Cint, paddingPixelsMinimumY::Cint) =
    ccall((:ncCropModeSolutionsSetParameters, libnuvu), Status,
          (NcCropModeSolutions, Cint, Cint, CropMode, Cint, Cint),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

# int ncCropModeSolutionsGetParameters( NcCropModeSolutions solutionSet, int* cropWidth, int* cropHeight, enum CropMode* mode, int* paddingPixelsMinimumX, int* paddingPixelsMinimumY);
@inline ncCropModeSolutionsGetParameters(solutionSet::NcCropModeSolutions, cropWidth::Ptr{Cint}, cropHeight::Ptr{Cint}, mode::Ptr{CropMode}, paddingPixelsMinimumX::Ptr{Cint}, paddingPixelsMinimumY::Ptr{Cint}) =
    ccall((:ncCropModeSolutionsGetParameters, libnuvu), Status,
          (NcCropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{CropMode}, Ptr{Cint}, Ptr{Cint}),
          solutionSet, cropWidth, cropHeight, mode, paddingPixelsMinimumX, paddingPixelsMinimumY)

# int ncCropModeSolutionsGetTotal( NcCropModeSolutions solutionSet, int* totalNbrSolutions);
@inline ncCropModeSolutionsGetTotal(solutionSet::NcCropModeSolutions, totalNbrSolutions::Ptr{Cint}) =
    ccall((:ncCropModeSolutionsGetTotal, libnuvu), Status,
          (NcCropModeSolutions, Ptr{Cint}),
          solutionSet, totalNbrSolutions)

# int ncCropModeSolutionsGetResult( NcCropModeSolutions solutionSet, unsigned int solutionIndex, float* figureOfMerit, int* startX_min, int* startX_max, int* startY_min, int* startY_max);
@inline ncCropModeSolutionsGetResult(solutionSet::NcCropModeSolutions, solutionIndex::Cuint, figureOfMerit::Ptr{Cfloat}, startX_min::Ptr{Cint}, startX_max::Ptr{Cint}, startY_min::Ptr{Cint}, startY_max::Ptr{Cint}) =
    ccall((:ncCropModeSolutionsGetResult, libnuvu), Status,
          (NcCropModeSolutions, Cuint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          solutionSet, solutionIndex, figureOfMerit, startX_min, startX_max, startY_min, startY_max)

# int ncCropModeSolutionsGetLocationRanges( NcCropModeSolutions solutionSet, int *offsetX_min, int *offsetX_max, int *offsetY_min, int *offsetY_max);
@inline ncCropModeSolutionsGetLocationRanges(solutionSet::NcCropModeSolutions, offsetX_min::Ptr{Cint}, offsetX_max::Ptr{Cint}, offsetY_min::Ptr{Cint}, offsetY_max::Ptr{Cint}) =
    ccall((:ncCropModeSolutionsGetLocationRanges, libnuvu), Status,
          (NcCropModeSolutions, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          solutionSet, offsetX_min, offsetX_max, offsetY_min, offsetY_max)

# int ncCropModeSolutionsGetResultAtLocation( NcCropModeSolutions solutionSet, int offsetX, int offsetY, float *figureOfMerit, int *startX_min, int *startX_max, int *startY_min, int *startY_max);
@inline ncCropModeSolutionsGetResultAtLocation(solutionSet::NcCropModeSolutions, offsetX::Cint, offsetY::Cint, figureOfMerit::Ptr{Cfloat}, startX_min::Ptr{Cint}, startX_max::Ptr{Cint}, startY_min::Ptr{Cint}, startY_max::Ptr{Cint}) =
    ccall((:ncCropModeSolutionsGetResultAtLocation, libnuvu), Status,
          (NcCropModeSolutions, Cint, Cint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}),
          solutionSet, offsetX, offsetY, figureOfMerit, startX_min, startX_max, startY_min, startY_max)

# int ncCropModeSolutionsClose( NcCropModeSolutions solutionSet );
@inline ncCropModeSolutionsClose(solutionSet::NcCropModeSolutions) =
    ccall((:ncCropModeSolutionsClose, libnuvu), Status,
          (NcCropModeSolutions, ),
          solutionSet)

# int ncCamCreateBias(NcCam cam, int nbrImages, enum ShutterMode biasShuttermode);
@inline ncCamCreateBias(cam::NcCam, nbrImages::Cint, biasShuttermode::ShutterMode) =
    ccall((:ncCamCreateBias, libnuvu), Status,
          (NcCam, Cint, ShutterMode),
          cam, nbrImages, biasShuttermode)

# int ncCamCancelBiasCreation(NcCam cam);
@inline ncCamCancelBiasCreation(cam::NcCam) =
    ccall((:ncCamCancelBiasCreation, libnuvu), Status,
          (NcCam, ),
          cam)

# int ncCamGetProcType(NcCam cam, int * type, int * nbrImagesPc);
@inline ncCamGetProcType(cam::NcCam, _type::Ptr{Cint}, nbrImagesPc::Ptr{Cint}) =
    ccall((:ncCamGetProcType, libnuvu), Status,
          (NcCam, Ptr{Cint}, Ptr{Cint}),
          cam, _type, nbrImagesPc)

# int ncCamSetProcType(NcCam cam, int type, int nbrImagesPc);
@inline ncCamSetProcType(cam::NcCam, _type::Cint, nbrImagesPc::Cint) =
    ccall((:ncCamSetProcType, libnuvu), Status,
          (NcCam, Cint, Cint),
          cam, _type, nbrImagesPc)

# int ncCamCreateBiasNewImageCallback(NcCam cam, void (*fct)(NcCam cam, int imageNo, void *data), void *data);
@inline ncCamCreateBiasNewImageCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamCreateBiasNewImageCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamStatsAddRegion(NcCam cam, int regionWidth, int regionHeight, int *regionIndex);
@inline ncCamStatsAddRegion(cam::NcCam, regionWidth::Cint, regionHeight::Cint, regionIndex::Ptr{Cint}) =
    ccall((:ncCamStatsAddRegion, libnuvu), Status,
          (NcCam, Cint, Cint, Ptr{Cint}),
          cam, regionWidth, regionHeight, regionIndex)

# int ncCamStatsRemoveRegion(NcCam cam, int regionIndex);
@inline ncCamStatsRemoveRegion(cam::NcCam, regionIndex::Cint) =
    ccall((:ncCamStatsRemoveRegion, libnuvu), Status,
          (NcCam, Cint),
          cam, regionIndex)

# int ncCamStatsResizeRegion(NcCam cam, int regionIndex, int regionWidth, int regionHeight);
@inline ncCamStatsResizeRegion(cam::NcCam, regionIndex::Cint, regionWidth::Cint, regionHeight::Cint) =
    ccall((:ncCamStatsResizeRegion, libnuvu), Status,
          (NcCam, Cint, Cint, Cint),
          cam, regionIndex, regionWidth, regionHeight)

# int ncCamStatsGetCrossSection(NcCam cam, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
@inline ncCamStatsGetCrossSection(cam::NcCam, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, statsCtxRegion::Ptr{Cdouble}, histo::Ptr{Ptr{Cdouble}}, crossSectionHorizontal::Ptr{Ptr{Cdouble}}, crossSectionVertical::Ptr{Ptr{Cdouble}}) =
    ccall((:ncCamStatsGetCrossSection, libnuvu), Status,
          (NcCam, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
          cam, regionIndex, image, xCoord, yCoord, statsCtxRegion, histo, crossSectionHorizontal, crossSectionVertical)

# int ncCamStatsGetGaussFit(NcCam cam, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSection);
@inline ncCamStatsGetGaussFit(cam::NcCam, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, maxAmplitude::Ptr{Cdouble}, gaussSumHorizontal::Ptr{Cdouble}, gaussSumVertical::Ptr{Cdouble}, useActualCrossSection::Cint) =
    ccall((:ncCamStatsGetGaussFit, libnuvu), Status,
          (NcCam, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
          cam, regionIndex, image, xCoord, yCoord, maxAmplitude, gaussSumHorizontal, gaussSumVertical, useActualCrossSection)

# int ncCamSetOnStatusAlertCallback(NcCam cam, void (*fct)(NcCam cam, void* data, int errorCode, const char * errorString), void * data);
@inline ncCamSetOnStatusAlertCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSetOnStatusAlertCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSetOnStatusUpdateCallback(NcCam cam, void (*fct)(NcCam cam, void* data), void * data);
@inline ncCamSetOnStatusUpdateCallback(cam::NcCam, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamSetOnStatusUpdateCallback, libnuvu), Status,
          (NcCam, Ptr{VoidCallback}, Ptr{Void}),
          cam, fct, data)

# int ncCamSetStatusPollRate(NcCam cam, int periodMs);
@inline ncCamSetStatusPollRate(cam::NcCam, periodMs::Cint) =
    ccall((:ncCamSetStatusPollRate, libnuvu), Status,
          (NcCam, Cint),
          cam, periodMs)

# int ncCamGetStatusPollRate(NcCam cam, int * periodMs);
@inline ncCamGetStatusPollRate(cam::NcCam, periodMs::Ptr{Cint}) =
    ccall((:ncCamGetStatusPollRate, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, periodMs)

# int ncProcOpen(int width, int height, NcProc* procCtx);
@inline ncProcOpen(width::Cint, height::Cint, procCtx::Ptr{NcProc}) =
    ccall((:ncProcOpen, libnuvu), Status,
          (Cint, Cint, Ptr{NcProc}),
          width, height, procCtx)

# int ncProcClose(NcProc ctx);
@inline ncProcClose(ctx::NcProc) =
    ccall((:ncProcClose, libnuvu), Status,
          (NcProc, ),
          ctx)

# int ncProcResize(NcProc ctx, int width, int height);
@inline ncProcResize(ctx::NcProc, width::Cint, height::Cint) =
    ccall((:ncProcResize, libnuvu), Status,
          (NcProc, Cint, Cint),
          ctx, width, height)

# int ncProcAddBiasImage(NcProc ctx, NcImage *bias);
@inline ncProcAddBiasImage(ctx::NcProc, bias::Ptr{NcImage}) =
    ccall((:ncProcAddBiasImage, libnuvu), Status,
          (NcProc, Ptr{NcImage}),
          ctx, bias)

# int ncProcComputeBias(NcProc ctx);
@inline ncProcComputeBias(ctx::NcProc) =
    ccall((:ncProcComputeBias, libnuvu), Status,
          (NcProc, ),
          ctx)

# int ncProcSetProcType(NcProc ctx, int type);
@inline ncProcSetProcType(ctx::NcProc, _type::Cint) =
    ccall((:ncProcSetProcType, libnuvu), Status,
          (NcProc, Cint),
          ctx, _type)

# int ncProcGetProcType(NcProc ctx, int *type);
@inline ncProcGetProcType(ctx::NcProc, _type::Ptr{Cint}) =
    ccall((:ncProcGetProcType, libnuvu), Status,
          (NcProc, Ptr{Cint}),
          ctx, _type)

# int ncProcProcessDataImageInPlace(NcProc ctx, NcImage *image);
@inline ncProcProcessDataImageInPlace(ctx::NcProc, image::Ptr{NcImage}) =
    ccall((:ncProcProcessDataImageInPlace, libnuvu), Status,
          (NcProc, Ptr{NcImage}),
          ctx, image)

# int ncProcProcessDataImageInPlaceForceType(NcProc ctx, NcImage *image, int procType);
@inline ncProcProcessDataImageInPlaceForceType(ctx::NcProc, image::Ptr{NcImage}, procType::Cint) =
    ccall((:ncProcProcessDataImageInPlaceForceType, libnuvu), Status,
          (NcProc, Ptr{NcImage}, Cint),
          ctx, image, procType)

# int ncProcGetImage(NcProc ctx, NcImage** image);
@inline ncProcGetImage(ctx::NcProc, image::Ptr{Ptr{NcImage}}) =
    ccall((:ncProcGetImage, libnuvu), Status,
          (NcProc, Ptr{Ptr{NcImage}}),
          ctx, image)

# int ncProcAddDataImage(NcProc ctx, NcImage *image);
@inline ncProcAddDataImage(ctx::NcProc, image::Ptr{NcImage}) =
    ccall((:ncProcAddDataImage, libnuvu), Status,
          (NcProc, Ptr{NcImage}),
          ctx, image)

# int ncProcReleaseImage(NcProc ctx, NcImage *image);
@inline ncProcReleaseImage(ctx::NcProc, image::Ptr{NcImage}) =
    ccall((:ncProcReleaseImage, libnuvu), Status,
          (NcProc, Ptr{NcImage}),
          ctx, image)

# int ncProcEmptyStack(NcProc ctx);
@inline ncProcEmptyStack(ctx::NcProc) =
    ccall((:ncProcEmptyStack, libnuvu), Status,
          (NcProc, ),
          ctx)

# int ncProcSetBiasClampLevel(NcProc ctx, int biasClampLevel);
@inline ncProcSetBiasClampLevel(ctx::NcProc, biasClampLevel::Cint) =
    ccall((:ncProcSetBiasClampLevel, libnuvu), Status,
          (NcProc, Cint),
          ctx, biasClampLevel)

# int ncProcGetBiasClampLevel(NcProc ctx, int* biasLevel);
@inline ncProcGetBiasClampLevel(ctx::NcProc, biasLevel::Ptr{Cint}) =
    ccall((:ncProcGetBiasClampLevel, libnuvu), Status,
          (NcProc, Ptr{Cint}),
          ctx, biasLevel)

# int ncProcSetOverscanLines(NcProc ctx, int overscanLines);
@inline ncProcSetOverscanLines(ctx::NcProc, overscanLines::Cint) =
    ccall((:ncProcSetOverscanLines, libnuvu), Status,
          (NcProc, Cint),
          ctx, overscanLines)

# int ncProcGetOverscanLines(NcProc ctx, int *overscanLines);
@inline ncProcGetOverscanLines(ctx::NcProc, overscanLines::Ptr{Cint}) =
    ccall((:ncProcGetOverscanLines, libnuvu), Status,
          (NcProc, Ptr{Cint}),
          ctx, overscanLines)

# int ncProcSave(NcProc ctx, const char *saveName, int overwriteFlag);
@inline ncProcSave(ctx::NcProc, saveName::Ptr{Cchar}, overwriteFlag::Cint) =
    ccall((:ncProcSave, libnuvu), Status,
          (NcProc, Ptr{Cchar}, Cint),
          ctx, saveName, overwriteFlag)

# int ncProcLoad(NcProc procCtx, const char *saveName);
@inline ncProcLoad(procCtx::NcProc, saveName::Ptr{Cchar}) =
    ccall((:ncProcLoad, libnuvu), Status,
          (NcProc, Ptr{Cchar}),
          procCtx, saveName)

# int ncProcSaveSetHeaderCallback(NcProc ctx, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncProcSaveSetHeaderCallback(ctx::NcProc, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncProcSaveSetHeaderCallback, libnuvu), Status,
          (NcProc, Ptr{VoidCallback}, Ptr{Void}),
          ctx, fct, data)

# int ncProcLoadSetHeaderCallback(NcProc ctx, void (*fct)(NcProc ctx, NcImageSaved *imageFile, void *data), void *data);
@inline ncProcLoadSetHeaderCallback(ctx::NcProc, fct::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncProcLoadSetHeaderCallback, libnuvu), Status,
          (NcProc, Ptr{VoidCallback}, Ptr{Void}),
          ctx, fct, data)

# int ncStatsOpen(int imageWidth, int imageHeight, NcStatsCtx** statsCtx);
@inline ncStatsOpen(imageWidth::Cint, imageHeight::Cint, statsCtx::Ptr{NcStatsCtx}) =
    ccall((:ncStatsOpen, libnuvu), Status,
          (Cint, Cint, Ptr{NcStatsCtx}),
          imageWidth, imageHeight, statsCtx)

# int ncStatsClose(NcStatsCtx *statsCtx);
@inline ncStatsClose(statsCtx::NcStatsCtx) =
    ccall((:ncStatsClose, libnuvu), Status,
          (NcStatsCtx, ),
          statsCtx)

# int ncStatsResize(NcStatsCtx *statsCtx, int imageWidth, int imageHeight);
@inline ncStatsResize(statsCtx::NcStatsCtx, imageWidth::Cint, imageHeight::Cint) =
    ccall((:ncStatsResize, libnuvu), Status,
          (NcStatsCtx, Cint, Cint),
          statsCtx, imageWidth, imageHeight)

# int ncStatsAddRegion(NcStatsCtx *statsCtx, int regionWidth, int regionHeight, int *regionIndex);
@inline ncStatsAddRegion(statsCtx::NcStatsCtx, regionWidth::Cint, regionHeight::Cint, regionIndex::Ptr{Cint}) =
    ccall((:ncStatsAddRegion, libnuvu), Status,
          (NcStatsCtx, Cint, Cint, Ptr{Cint}),
          statsCtx, regionWidth, regionHeight, regionIndex)

# int ncStatsRemoveRegion(NcStatsCtx *statsCtx, int regionIndex);
@inline ncStatsRemoveRegion(statsCtx::NcStatsCtx, regionIndex::Cint) =
    ccall((:ncStatsRemoveRegion, libnuvu), Status,
          (NcStatsCtx, Cint),
          statsCtx, regionIndex)

# int ncStatsResizeRegion(NcStatsCtx *statsCtx, int regionIndex, int regionWidth, int regionHeight);
@inline ncStatsResizeRegion(statsCtx::NcStatsCtx, regionIndex::Cint, regionWidth::Cint, regionHeight::Cint) =
    ccall((:ncStatsResizeRegion, libnuvu), Status,
          (NcStatsCtx, Cint, Cint, Cint),
          statsCtx, regionIndex, regionWidth, regionHeight)

# int ncStatsGetHistoCrossSection(NcStatsCtx *statsCtx, int regionIndex, const NcImage *image, int xCoord, int yCoord, double statsCtxRegion[5], double **histo, double **crossSectionHorizontal, double **crossSectionVertical);
@inline ncStatsGetHistoCrossSection(statsCtx::NcStatsCtx, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, statsCtxRegion::Ptr{Cdouble}, histo::Ptr{Ptr{Cdouble}}, crossSectionHorizontal::Ptr{Ptr{Cdouble}}, crossSectionVertical::Ptr{Ptr{Cdouble}}) =
    ccall((:ncStatsGetHistoCrossSection, libnuvu), Status,
          (NcStatsCtx, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}, Ptr{Ptr{Cdouble}}),
          statsCtx, regionIndex, image, xCoord, yCoord, statsCtxRegion, histo, crossSectionHorizontal, crossSectionVertical)

# int ncStatsGetGaussFit(NcStatsCtx *statsCtx, int regionIndex, const NcImage *image, int xCoord, int yCoord, double *maxAmplitude, double gaussSumHorizontal[3], double gaussSumVertical[3], int useActualCrossSectionFlag);
@inline ncStatsGetGaussFit(statsCtx::NcStatsCtx, regionIndex::Cint, image::Ptr{NcImage}, xCoord::Cint, yCoord::Cint, maxAmplitude::Ptr{Cdouble}, gaussSumHorizontal::Ptr{Cdouble}, gaussSumVertical::Ptr{Cdouble}, useActualCrossSectionFlag::Cint) =
    ccall((:ncStatsGetGaussFit, libnuvu), Status,
          (NcStatsCtx, Cint, Ptr{NcImage}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint),
          statsCtx, regionIndex, image, xCoord, yCoord, maxAmplitude, gaussSumHorizontal, gaussSumVertical, useActualCrossSectionFlag)

# int ncCamSetSerialCarTime(NcCam cam, double serialCarTime);
@inline ncCamSetSerialCarTime(cam::NcCam, serialCarTime::Cdouble) =
    ccall((:ncCamSetSerialCarTime, libnuvu), Status,
          (NcCam, Cdouble),
          cam, serialCarTime)

# int ncCamGetSerialCarTime(NcCam cam, int cameraRequest, double* serialCarTime);
@inline ncCamGetSerialCarTime(cam::NcCam, cameraRequest::Cint, serialCarTime::Ptr{Cdouble}) =
    ccall((:ncCamGetSerialCarTime, libnuvu), Status,
          (NcCam, Cint, Ptr{Cdouble}),
          cam, cameraRequest, serialCarTime)

# int ncGrabParamSupportedInt(NcGrab grab, const char * paramName, int * supported);
@inline ncGrabParamSupportedInt(grab::NcGrab, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncGrabParamSupportedInt, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, supported)

# int ncGrabParamSupportedDbl(NcGrab grab, const char * paramName, int * supported);
@inline ncGrabParamSupportedDbl(grab::NcGrab, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncGrabParamSupportedDbl, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, supported)

# int ncGrabParamSupportedStr(NcGrab grab, const char * paramName, int * supported);
@inline ncGrabParamSupportedStr(grab::NcGrab, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncGrabParamSupportedStr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, supported)

# int ncGrabParamSupportedVoidPtr(NcGrab grab, const char * paramName, int * supported);
@inline ncGrabParamSupportedVoidPtr(grab::NcGrab, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncGrabParamSupportedVoidPtr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, supported)

# int ncGrabParamSupportedCallback(NcGrab grab, const char * paramName, int * supported);
@inline ncGrabParamSupportedCallback(grab::NcGrab, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncGrabParamSupportedCallback, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, supported)

# int ncGrabParamGetCountInt(NcGrab grab, int * count);
@inline ncGrabParamGetCountInt(grab::NcGrab, count::Ptr{Cint}) =
    ccall((:ncGrabParamGetCountInt, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, count)

# int ncGrabParamGetCountDbl(NcGrab grab, int * count);
@inline ncGrabParamGetCountDbl(grab::NcGrab, count::Ptr{Cint}) =
    ccall((:ncGrabParamGetCountDbl, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, count)

# int ncGrabParamGetCountStr(NcGrab grab, int * count);
@inline ncGrabParamGetCountStr(grab::NcGrab, count::Ptr{Cint}) =
    ccall((:ncGrabParamGetCountStr, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, count)

# int ncGrabParamGetCountVoidPtr(NcGrab grab, int * count);
@inline ncGrabParamGetCountVoidPtr(grab::NcGrab, count::Ptr{Cint}) =
    ccall((:ncGrabParamGetCountVoidPtr, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, count)

# int ncGrabParamGetCountCallback(NcGrab grab, int * count);
@inline ncGrabParamGetCountCallback(grab::NcGrab, count::Ptr{Cint}) =
    ccall((:ncGrabParamGetCountCallback, libnuvu), Status,
          (NcGrab, Ptr{Cint}),
          grab, count)

# int ncGrabParamGetNameInt(NcGrab grab, int index, const char ** name);
@inline ncGrabParamGetNameInt(grab::NcGrab, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncGrabParamGetNameInt, libnuvu), Status,
          (NcGrab, Cint, Ptr{Ptr{Cchar}}),
          grab, index, name)

# int ncGrabParamGetNameDbl(NcGrab grab, int index, const char ** name);
@inline ncGrabParamGetNameDbl(grab::NcGrab, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncGrabParamGetNameDbl, libnuvu), Status,
          (NcGrab, Cint, Ptr{Ptr{Cchar}}),
          grab, index, name)

# int ncGrabParamGetNameStr(NcGrab grab, int index, const char ** name);
@inline ncGrabParamGetNameStr(grab::NcGrab, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncGrabParamGetNameStr, libnuvu), Status,
          (NcGrab, Cint, Ptr{Ptr{Cchar}}),
          grab, index, name)

# int ncGrabParamGetNameVoidPtr(NcGrab grab, int index, const char ** name);
@inline ncGrabParamGetNameVoidPtr(grab::NcGrab, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncGrabParamGetNameVoidPtr, libnuvu), Status,
          (NcGrab, Cint, Ptr{Ptr{Cchar}}),
          grab, index, name)

# int ncGrabParamGetNameCallback(NcGrab grab, int index, const char ** name);
@inline ncGrabParamGetNameCallback(grab::NcGrab, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncGrabParamGetNameCallback, libnuvu), Status,
          (NcGrab, Cint, Ptr{Ptr{Cchar}}),
          grab, index, name)

# int ncGrabParamSetInt(NcGrab grab, const char * paramName, int value);
@inline ncGrabParamSetInt(grab::NcGrab, paramName::Ptr{Cchar}, value::Cint) =
    ccall((:ncGrabParamSetInt, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Cint),
          grab, paramName, value)

# int ncGrabParamSetDbl(NcGrab grab, const char * paramName, double value);
@inline ncGrabParamSetDbl(grab::NcGrab, paramName::Ptr{Cchar}, value::Cdouble) =
    ccall((:ncGrabParamSetDbl, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Cdouble),
          grab, paramName, value)

# int ncGrabParamSetStr(NcGrab grab, const char * paramName, const char * value);
@inline ncGrabParamSetStr(grab::NcGrab, paramName::Ptr{Cchar}, value::Ptr{Cchar}) =
    ccall((:ncGrabParamSetStr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cchar}),
          grab, paramName, value)

# int ncGrabParamSetVoidPtr(NcGrab grab, const char * paramName, void * value);
@inline ncGrabParamSetVoidPtr(grab::NcGrab, paramName::Ptr{Cchar}, value::Ptr{Void}) =
    ccall((:ncGrabParamSetVoidPtr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Void}),
          grab, paramName, value)

# int ncGrabParamSetCallback(NcGrab grab, const char * paramName, void(*callback)(void*), void * data);
@inline ncGrabParamSetCallback(grab::NcGrab, paramName::Ptr{Cchar}, callback::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncGrabParamSetCallback, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{VoidCallback}, Ptr{Void}),
          grab, paramName, callback, data)

# int ncGrabParamUnsetInt(NcGrab grab, const char * paramName);
@inline ncGrabParamUnsetInt(grab::NcGrab, paramName::Ptr{Cchar}) =
    ccall((:ncGrabParamUnsetInt, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, paramName)

# int ncGrabParamUnsetDbl(NcGrab grab, const char * paramName);
@inline ncGrabParamUnsetDbl(grab::NcGrab, paramName::Ptr{Cchar}) =
    ccall((:ncGrabParamUnsetDbl, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, paramName)

# int ncGrabParamUnsetStr(NcGrab grab, const char * paramName);
@inline ncGrabParamUnsetStr(grab::NcGrab, paramName::Ptr{Cchar}) =
    ccall((:ncGrabParamUnsetStr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, paramName)

# int ncGrabParamUnsetVoidPtr(NcGrab grab, const char * paramName);
@inline ncGrabParamUnsetVoidPtr(grab::NcGrab, paramName::Ptr{Cchar}) =
    ccall((:ncGrabParamUnsetVoidPtr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, paramName)

# int ncGrabParamUnsetCallback(NcGrab grab, const char * paramName);
@inline ncGrabParamUnsetCallback(grab::NcGrab, paramName::Ptr{Cchar}) =
    ccall((:ncGrabParamUnsetCallback, libnuvu), Status,
          (NcGrab, Ptr{Cchar}),
          grab, paramName)

# int ncGrabParamGetInt(NcGrab grab, const char * paramName, int * value);
@inline ncGrabParamGetInt(grab::NcGrab, paramName::Ptr{Cchar}, value::Ptr{Cint}) =
    ccall((:ncGrabParamGetInt, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, value)

# int ncGrabParamGetDbl(NcGrab grab, const char * paramName, double * value);
@inline ncGrabParamGetDbl(grab::NcGrab, paramName::Ptr{Cchar}, value::Ptr{Cdouble}) =
    ccall((:ncGrabParamGetDbl, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cdouble}),
          grab, paramName, value)

# int ncGrabParamGetStr(NcGrab grab, const char * paramName, char * outBuffer, int bufferSize);
@inline ncGrabParamGetStr(grab::NcGrab, paramName::Ptr{Cchar}, outBuffer::Ptr{Cchar}, bufferSize::Cint) =
    ccall((:ncGrabParamGetStr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cchar}, Cint),
          grab, paramName, outBuffer, bufferSize)

# int ncGrabParamGetStrSize(NcGrab grab, const char * paramName, int * valueSize);
@inline ncGrabParamGetStrSize(grab::NcGrab, paramName::Ptr{Cchar}, valueSize::Ptr{Cint}) =
    ccall((:ncGrabParamGetStrSize, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Cint}),
          grab, paramName, valueSize)

# int ncGrabParamGetVoidPtr(NcGrab grab, const char * paramName, void ** value);
@inline ncGrabParamGetVoidPtr(grab::NcGrab, paramName::Ptr{Cchar}, value::Ptr{Ptr{Void}}) =
    ccall((:ncGrabParamGetVoidPtr, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Ptr{Void}}),
          grab, paramName, value)

# int ncGrabParamGetCallback(NcGrab grab, const char * paramName, void(**callback)(void*), void ** data);
@inline ncGrabParamGetCallback(grab::NcGrab, paramName::Ptr{Cchar}, callback::Ptr{Ptr{VoidCallback}}, data::Ptr{Ptr{Void}}) =
    ccall((:ncGrabParamGetCallback, libnuvu), Status,
          (NcGrab, Ptr{Cchar}, Ptr{Ptr{VoidCallback}}, Ptr{Ptr{Void}}),
          grab, paramName, callback, data)

# int ncCamParamSupportedInt(NcCam cam, const char * paramName, int * supported);
@inline ncCamParamSupportedInt(cam::NcCam, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncCamParamSupportedInt, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, supported)

# int ncCamParamSupportedDbl(NcCam cam, const char * paramName, int * supported);
@inline ncCamParamSupportedDbl(cam::NcCam, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncCamParamSupportedDbl, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, supported)

# int ncCamParamSupportedStr(NcCam cam, const char * paramName, int * supported);
@inline ncCamParamSupportedStr(cam::NcCam, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncCamParamSupportedStr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, supported)

# int ncCamParamSupportedVoidPtr(NcCam cam, const char * paramName, int * supported);
@inline ncCamParamSupportedVoidPtr(cam::NcCam, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncCamParamSupportedVoidPtr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, supported)

# int ncCamParamSupportedCallback(NcCam cam, const char * paramName, int * supported);
@inline ncCamParamSupportedCallback(cam::NcCam, paramName::Ptr{Cchar}, supported::Ptr{Cint}) =
    ccall((:ncCamParamSupportedCallback, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, supported)

# int ncCamParamGetCountInt(NcCam cam, int * count);
@inline ncCamParamGetCountInt(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamParamGetCountInt, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamParamGetCountDbl(NcCam cam, int * count);
@inline ncCamParamGetCountDbl(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamParamGetCountDbl, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamParamGetCountStr(NcCam cam, int * count);
@inline ncCamParamGetCountStr(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamParamGetCountStr, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamParamGetCountVoidPtr(NcCam cam, int * count);
@inline ncCamParamGetCountVoidPtr(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamParamGetCountVoidPtr, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamParamGetCountCallback(NcCam cam, int * count);
@inline ncCamParamGetCountCallback(cam::NcCam, count::Ptr{Cint}) =
    ccall((:ncCamParamGetCountCallback, libnuvu), Status,
          (NcCam, Ptr{Cint}),
          cam, count)

# int ncCamParamGetNameInt(NcCam cam, int index, const char ** name);
@inline ncCamParamGetNameInt(cam::NcCam, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamParamGetNameInt, libnuvu), Status,
          (NcCam, Cint, Ptr{Ptr{Cchar}}),
          cam, index, name)

# int ncCamParamGetNameDbl(NcCam cam, int index, const char ** name);
@inline ncCamParamGetNameDbl(cam::NcCam, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamParamGetNameDbl, libnuvu), Status,
          (NcCam, Cint, Ptr{Ptr{Cchar}}),
          cam, index, name)

# int ncCamParamGetNameStr(NcCam cam, int index, const char ** name);
@inline ncCamParamGetNameStr(cam::NcCam, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamParamGetNameStr, libnuvu), Status,
          (NcCam, Cint, Ptr{Ptr{Cchar}}),
          cam, index, name)

# int ncCamParamGetNameVoidPtr(NcCam cam, int index, const char ** name);
@inline ncCamParamGetNameVoidPtr(cam::NcCam, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamParamGetNameVoidPtr, libnuvu), Status,
          (NcCam, Cint, Ptr{Ptr{Cchar}}),
          cam, index, name)

# int ncCamParamGetNameCallback(NcCam cam, int index, const char ** name);
@inline ncCamParamGetNameCallback(cam::NcCam, index::Cint, name::Ptr{Ptr{Cchar}}) =
    ccall((:ncCamParamGetNameCallback, libnuvu), Status,
          (NcCam, Cint, Ptr{Ptr{Cchar}}),
          cam, index, name)

# int ncCamParamSetInt(NcCam cam, const char * paramName, int value);
@inline ncCamParamSetInt(cam::NcCam, paramName::Ptr{Cchar}, value::Cint) =
    ccall((:ncCamParamSetInt, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Cint),
          cam, paramName, value)

# int ncCamParamSetDbl(NcCam cam, const char * paramName, double value);
@inline ncCamParamSetDbl(cam::NcCam, paramName::Ptr{Cchar}, value::Cdouble) =
    ccall((:ncCamParamSetDbl, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Cdouble),
          cam, paramName, value)

# int ncCamParamSetStr(NcCam cam, const char * paramName, const char * value);
@inline ncCamParamSetStr(cam::NcCam, paramName::Ptr{Cchar}, value::Ptr{Cchar}) =
    ccall((:ncCamParamSetStr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cchar}),
          cam, paramName, value)

# int ncCamParamSetVoidPtr(NcCam cam, const char * paramName, void * value);
@inline ncCamParamSetVoidPtr(cam::NcCam, paramName::Ptr{Cchar}, value::Ptr{Void}) =
    ccall((:ncCamParamSetVoidPtr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Void}),
          cam, paramName, value)

# int ncCamParamSetCallback(NcCam cam, const char * paramName, void(*callback)(void*), void * data);
@inline ncCamParamSetCallback(cam::NcCam, paramName::Ptr{Cchar}, callback::Ptr{VoidCallback}, data::Ptr{Void}) =
    ccall((:ncCamParamSetCallback, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{VoidCallback}, Ptr{Void}),
          cam, paramName, callback, data)

# int ncCamParamUnsetInt(NcCam cam, const char * paramName);
@inline ncCamParamUnsetInt(cam::NcCam, paramName::Ptr{Cchar}) =
    ccall((:ncCamParamUnsetInt, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, paramName)

# int ncCamParamUnsetDbl(NcCam cam, const char * paramName);
@inline ncCamParamUnsetDbl(cam::NcCam, paramName::Ptr{Cchar}) =
    ccall((:ncCamParamUnsetDbl, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, paramName)

# int ncCamParamUnsetStr(NcCam cam, const char * paramName);
@inline ncCamParamUnsetStr(cam::NcCam, paramName::Ptr{Cchar}) =
    ccall((:ncCamParamUnsetStr, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, paramName)

# int ncCamParamUnsetVoidPtr(NcCam cam, const char * paramName);
@inline ncCamParamUnsetVoidPtr(cam::NcCam, paramName::Ptr{Cchar}) =
    ccall((:ncCamParamUnsetVoidPtr, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, paramName)

# int ncCamParamUnsetCallback(NcCam cam, const char * paramName);
@inline ncCamParamUnsetCallback(cam::NcCam, paramName::Ptr{Cchar}) =
    ccall((:ncCamParamUnsetCallback, libnuvu), Status,
          (NcCam, Ptr{Cchar}),
          cam, paramName)

# int ncCamParamGetInt(NcCam cam, const char * paramName, int * value);
@inline ncCamParamGetInt(cam::NcCam, paramName::Ptr{Cchar}, value::Ptr{Cint}) =
    ccall((:ncCamParamGetInt, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, value)

# int ncCamParamGetDbl(NcCam cam, const char * paramName, double * value);
@inline ncCamParamGetDbl(cam::NcCam, paramName::Ptr{Cchar}, value::Ptr{Cdouble}) =
    ccall((:ncCamParamGetDbl, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cdouble}),
          cam, paramName, value)

# int ncCamParamGetStr(NcCam cam, const char * paramName, char * outBuffer, int bufferSize);
@inline ncCamParamGetStr(cam::NcCam, paramName::Ptr{Cchar}, outBuffer::Ptr{Cchar}, bufferSize::Cint) =
    ccall((:ncCamParamGetStr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cchar}, Cint),
          cam, paramName, outBuffer, bufferSize)

# int ncCamParamGetStrSize(NcCam cam, const char * paramName, int * valueSize);
@inline ncCamParamGetStrSize(cam::NcCam, paramName::Ptr{Cchar}, valueSize::Ptr{Cint}) =
    ccall((:ncCamParamGetStrSize, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Cint}),
          cam, paramName, valueSize)

# int ncCamParamGetVoidPtr(NcCam cam, const char * paramName, void ** value);
@inline ncCamParamGetVoidPtr(cam::NcCam, paramName::Ptr{Cchar}, value::Ptr{Ptr{Void}}) =
    ccall((:ncCamParamGetVoidPtr, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Ptr{Void}}),
          cam, paramName, value)

# int ncCamParamGetCallback(NcCam cam, const char * paramName, void(**callback)(void*), void ** data);
@inline ncCamParamGetCallback(cam::NcCam, paramName::Ptr{Cchar}, callback::Ptr{Ptr{VoidCallback}}, data::Ptr{Ptr{Void}}) =
    ccall((:ncCamParamGetCallback, libnuvu), Status,
          (NcCam, Ptr{Cchar}, Ptr{Ptr{VoidCallback}}, Ptr{Ptr{Void}}),
          cam, paramName, callback, data)

