# Conversion of C Code to Julia

This document provides information for converting in Julia C calls to the C
application programming interface (API) of the Nüvü Camēras software
development kit (SDK).

The low level interface is in a `NC` module which exports nothing, so all
references to methods, constants, *etc.* of this module have to be prefixed by
`NC.`.  For this reason, the prefixes `nc` (for functions), `Nc` (for some
types) or `NC_` (for some constants) used in the C API have been stripped.


## Data Types

Apart from basic C types, the Nüvü Camēras SDK defines a number of opaque
structures (thus only pointers to such structures are involved in the C API),
enumerations and some typedef's.


### Opaque Structures

The Julia interface defines types embedding a pointer for each opaque structure
of the SDK summarized by the following table.

| Julia Type           | Equivallent C Structure Type        | Equivallent C Type    |
| :------------------- | :---------------------------------- | :-------------------- |
| `Cam`                | `struct NcCamHandle*`               | `NcCam`               |
| `Grab`               | `struct NcGrabHandle*`              | `NcGrab`              |
| `ImageParams{T}` (*) | `struct NcImagParamHandle*`         | `ImageParams`         |
| `Proc`               | `struct NcProcHandle*`              | `NcProc`              |
| `CtrlList`           | `struct NcCtrlListHandle*`          | `NcCtrlList`          |
| `CropModeSolutions`  | `struct NcCropModeSolutionsHandle*` | `NcCropModeSolutions` |
| `ImageSaved`         | `struct NcImageSavedHandle*`        | `NcImageSaved*`       |
| `StatsCtx`           | `struct _NcStatsCtx*`               | `NcStatsCtx*`         |

(*) Julia type `ImageParams{T}` is parameterized by `T` which is either `Cam`
or `Grab` to keep track of its origin.


### Enumerations

The following table lists all enumerations (the names of the enumeration values
are unchanged).

| Julia Type         | C Enumeration Type        |
| :----------------- | :------------------------ |
| `Ampli`            | `enum Ampli`              |
| `CommType`         | `enum CommType`           |
| `DetectorType`     | `enum DetectorType`       |
| `Features` (*)     | `enum Features`           |
| `TemperatureType`  | `enum NcTemperatureType`  |
| `PortUnusedReason` | `enum NcPortUnusedReason` |
| `ShutterMode`      | `enum ShutterMode`        |
| `TriggerMode`      | `enum TriggerMode`        |
| `CropMode`         | `enum CropMode`           |
| `ExtShutter`       | `enum ExtShutter`         |
| `ExtPolarity`      | `enum ExtPolarity`        |
| `ImageFormat`      | `enum ImageFormat`        |
| `ImageDataType`    | `enum ImageDataType`      |
| `HeaderDataType`   | `enum HeaderDataType`     |
| `ImageCompression` | `enum ImageCompression`   |
| `ProcType`         | `enum ProcType`           |
| `TimestampMode`    | `enum TimestampMode`      |
| `VersionType`      | `enum VersionType`        |
| `SdkDataTypes`     | `enum NcSdkDataTypes`     |

(*) The SDK also defines `Param` as an alias to the `Features` enumeration but
this alias is not used.


### Other Types

Julia type `Image` is the equivallent to the C type `NcImage` which defines the
type of the pixels of an image.  In C, `NcImage` is an alias to `unsigned
short`; hence `Image` is defined as a constant equal to `UInt16` in Julia.


### Callbacks

All callbacks are passed as `Ptr{Void}` in Julia using `cfunction` to get the
address to the Julia function.  Remember to compute such addresses in the
`__init__` method of the module if pre-compilation is activated.


### Unused Types

C types `NcProcCtx`, `NcDevice` and `NcCtxSaved` (respectively defined as
`struct NcProcHandle`, `struct _NcDevice*` and `fitsfile`) are not used by any
function of the SDK.


## Interfaced Functions

The following table lists the interfaced C functions of the Nüvü Camēras SDK
and the corresponding Julia methods.

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncWriteFileHeader                        |                                     |
| ncReadFileHeader                         |                                     |
| ncImageGetFileFormat                     |                                     |

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncControllerListOpen                     | open                                |
| ncControllerListOpenBasic                | open                                |
| ncControllerListFree                     | close                               |
| ncControllerListGetSize                  | getSize                             |
| ncControllerListGetSerial                | getSerial                           |
| ncControllerListGetModel                 | getModel                            |
| ncControllerListGetPortUnit              | getPortUnit                         |
| ncControllerListGetPortChannel           | getPortChannel                      |
| ncControllerListGetPortInterface         | getPortInterface                    |
| ncControllerListGetUniqueID              | getUniqueID                         |
| ncControllerListGetFullSizeSize          | getFullSizeSize                     |
| ncControllerListGetDetectorSize          | getDetectorSize                     |
| ncControllerListGetDetectorType          | getDetectorType                     |
| ncControllerListGetFreePortCount         | getFreePortCount                    |
| ncControllerListGetFreePortUnit          | getFreePortUnit                     |
| ncControllerListGetFreePortChannel       | getFreePortChannel                  |
| ncControllerListGetFreePortInterface     | getFreePortInterface                |
| ncControllerListGetFreePortUniqueID      | getFreePortUniqueID                 |
| ncControllerListGetFreePortReason        | getFreePortReason                   |
| ncControllerListGetPluginCount           | getPluginCount                      |
| ncControllerListGetPluginName            | getPluginName                       |

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncGrabSetOpenMacAdress                   | setOpenMacAddress                   |
| ncGrabOpen                               | open                                |
| ncGrabOpenFromList                       | open                                |
| ncGrabClose                              | close                               |
| ncGrabSetHeartbeat                       | setHeartbeat                        |
| ncGrabGetHeartbeat                       | getHeartbeat                        |
| ncGrabStart                              | start                               |
| ncGrabAbort                              | abort                               |
| ncGrabRead                               |                                     |
| ncGrabReadChronological                  |                                     |
| ncGrabReadChronologicalNonBlocking       |                                     |
| ncGrabOpenImageParams                    | open                                |
| ncGrabGetImageParams                     | getImageParams                      |
| ncGrabCloseImageParams                   | close                               |
| ncGrabFlushReadQueues                    | flushReadQueues                     |
| ncGrabGetOverrun                         | getOverrun                          |
| ncGrabGetNbrDroppedImages                | getNbrDroppedImages                 |
| ncGrabGetNbrTimeout                      | getNbrTimeout                       |
| ncGrabSetTimeout                         | setTimeout                          |
| ncGrabGetTimeout                         | getTimeout                          |
| ncGrabSetSize                            | setSize                             |
| ncGrabGetSize                            | getSize                             |
| ncGrabSaveImage                          |                                     |
| ncGrabSaveImageEx                        |                                     |
| ncGrabStartSaveAcquisition               |                                     |
| ncGrabStopSaveAcquisition                | stopSaveAcquisition                 |
| ncGrabSaveImageSetHeaderCallback         |                                     |
| ncGrabSaveImageWriteCallback             |                                     |
| ncGrabSaveImageCloseCallback             |                                     |
| ncGrabSaveImageSetCompressionType        |                                     |
| ncGrabSaveImageGetCompressionType        |                                     |
| ncGrabSaveParam                          |                                     |
| ncGrabLoadParam                          |                                     |
| ncGrabSaveParamSetHeaderCallback         |                                     |
| ncGrabLoadParamSetHeaderCallback         |                                     |
| ncGrabSetTimestampMode                   | setTimestampMode                    |
| ncGrabGetTimestampMode                   | getTimestampMode                    |
| ncGrabSetTimestampInternal               | setTimestampInternal                |
| ncGrabGetCtrlTimestamp                   | getCtrlTimestamp                    |
| ncGrabGetHostSystemTimestamp             | getHostSystemTimestamp              |
| ncGrabParamAvailable                     |                                     |
| ncGrabResetTimer                         |                                     |
| ncGrabSetEvent                           | setEvent                            |
| ncGrabCancelEvent                        |                                     |
| ncGrabSetSerialTimeout                   | setSerialTimeout                    |
| ncGrabGetSerialTimeout                   | getSerialTimeout                    |
| ncGrabSetBaudrate                        | setBaudrate                         |
| ncGrabSendSerialBinaryComm               |                                     |
| ncGrabWaitSerialCmd                      |                                     |
| ncGrabRecSerial                          |                                     |
| ncGrabGetSerialUnreadBytes               | getSerialUnreadBytes                |
| ncGrabNbrImagesAcquired                  |                                     |
| ncGrabGetVersion                         | getVersion                          |
| ncGrabCreateBias                         |                                     |
| ncGrabCancelBiasCreation                 | cancelBiasCreation                  |
| ncGrabSetProcType                        | setProcType                         |
| ncGrabGetProcType                        | getProcType                         |
| ncGrabCreateBiasNewImageCallback         |                                     |
| ncGrabStatsAddRegion                     |                                     |
| ncGrabStatsRemoveRegion                  |                                     |
| ncGrabStatsResizeRegion                  |                                     |
| ncGrabStatsGetCrossSection               |                                     |
| ncGrabStatsGetGaussFit                   |                                     |
| ncGrabParamSupportedInt                  | supportedParamInt                   |
| ncGrabParamSupportedDbl                  | supportedParamDbl                   |
| ncGrabParamSupportedStr                  | supportedParamStr                   |
| ncGrabParamSupportedVoidPtr              | supportedParamVoidPtr               |
| ncGrabParamSupportedCallback             | supportedParamCallback              |
| ncGrabParamGetCountInt                   | getParamCountInt                    |
| ncGrabParamGetCountDbl                   | getParamCountDbl                    |
| ncGrabParamGetCountStr                   | getParamCountStr                    |
| ncGrabParamGetCountVoidPtr               | getParamCountVoidPtr                |
| ncGrabParamGetCountCallback              | getParamCountCallback               |
| ncGrabParamGetNameInt                    | getParamNameInt                     |
| ncGrabParamGetNameDbl                    | getParamNameDbl                     |
| ncGrabParamGetNameStr                    | getParamNameStr                     |
| ncGrabParamGetNameVoidPtr                | getParamNameVoidPtr                 |
| ncGrabParamGetNameCallback               | getParamNameCallback                |
| ncGrabParamSetInt                        | setParamInt                         |
| ncGrabParamSetDbl                        | setParamDbl                         |
| ncGrabParamSetStr                        | setParamStr                         |
| ncGrabParamSetVoidPtr                    | setParamVoidPtr                     |
| ncGrabParamSetCallback                   | setParamCallback                    |
| ncGrabParamUnsetInt                      | unsetParamInt                       |
| ncGrabParamUnsetDbl                      | unsetParamDbl                       |
| ncGrabParamUnsetStr                      | unsetParamStr                       |
| ncGrabParamUnsetVoidPtr                  | unsetParamVoidPtr                   |
| ncGrabParamUnsetCallback                 | unsetParamCallback                  |
| ncGrabParamGetInt                        | getParamInt                         |
| ncGrabParamGetDbl                        | getParamDbl                         |
| ncGrabParamGetStr                        | getParamStr                         |
| ncGrabParamGetStrSize                    | getParamStrSize                     |
| ncGrabParamGetVoidPtr                    | getParamVoidPtr                     |
| ncGrabParamGetCallback                   | getParamCallback                    |

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncCamSetOpenMacAdress                    | setOpenMacAddress                   |
| ncCamOpen                                | open                                |
| ncCamOpenFromList                        | open                                |
| ncCamClose                               | close                               |
| ncCamReadyToClose                        | readyToClose                        |
| ncCamSetHeartbeat                        | setHeartbeat                        |
| ncCamGetHeartbeat                        | getHeartbeat                        |
| ncCamStart                               | start                               |
| ncCamPrepareAcquisition                  | prepareAcquisition                  |
| ncCamBeginAcquisition                    | beginAcquisition                    |
| ncCamAbort                               | abort                               |
| ncSaveImage                              |                                     |
| ncCamOpenImageParams                     | open                                |
| ncCamGetImageParams                      | getImageParams                      |
| ncCamCloseImageParams                    |                                     |
| ncCamRead                                |                                     |
| ncCamReadUInt32                          |                                     |
| ncCamReadFloat                           |                                     |
| ncCamReadChronological                   |                                     |
| ncCamReadUInt32Chronological             |                                     |
| ncCamReadFloatChronological              |                                     |
| ncCamReadChronologicalNonBlocking        |                                     |
| ncCamReadUInt32ChronologicalNonBlocking  |                                     |
| ncCamReadFloatChronologicalNonBlocking   |                                     |
| ncCamAllocUInt32Image                    |                                     |
| ncCamFreeUInt32Image                     |                                     |
| ncCamFlushReadQueues                     | flushReadQueues                     |
| ncCamGetOverrun                          | getOverrun                          |
| ncCamGetNbrDroppedImages                 | getNbrDroppedImages                 |
| ncCamGetNbrTimeout                       | getNbrTimeout                       |
| ncCamSetTimeout                          | setTimeout                          |
| ncCamGetTimeout                          | getTimeout                          |
| ncCamGetSize                             | getSize                             |
| ncCamGetMaxSize                          | getMaxSize                          |
| ncCamGetOverscanLines                    | getOverscanLines                    |
| ncCamGetFrameLatency                     | getFrameLatency                     |
| ncCamSaveImage                           |                                     |
| ncCamSaveUInt32Image                     |                                     |
| ncCamSaveFloatImage                      |                                     |
| ncCamSaveImageEx                         |                                     |
| ncCamStartSaveAcquisition                |                                     |
| ncCamStopSaveAcquisition                 | stopSaveAcquisition                 |
| ncCamSaveImageSetHeaderCallback          |                                     |
| ncCamSaveImageWriteCallback              |                                     |
| ncCamSaveImageCloseCallback              |                                     |
| ncCamSaveImageSetCompressionType         |                                     |
| ncCamSaveImageGetCompressionType         |                                     |
| ncCamResetTimer                          |                                     |
| ncCamSetEvent                            | setEvent                            |
| ncCamCancelEvent                         |                                     |
| ncCamSetTimestampMode                    | setTimestampMode                    |
| ncCamGetTimestampMode                    | getTimestampMode                    |
| ncCamSetTimestampInternal                | setTimestampInternal                |
| ncCamGetCtrlTimestamp                    | getCtrlTimestamp                    |
| ncCamGetHostSystemTimestamp              | getHostSystemTimestamp              |
| ncCamParamAvailable                      |                                     |
| ncCamSaveParam                           |                                     |
| ncCamLoadParam                           |                                     |
| ncCamSaveParamSetHeaderCallback          |                                     |
| ncCamLoadParamSetHeaderCallback          |                                     |
| ncCamSetReadoutMode                      | setReadoutMode                      |
| ncCamGetCurrentReadoutMode               | getCurrentReadoutMode               |
| ncCamGetReadoutMode                      | getReadoutMode                      |
| ncCamGetNbrReadoutModes                  | getNbrReadoutModes                  |
| ncCamGetReadoutTime                      | getReadoutTime                      |
| ncCamGetAmpliTypeAvail                   | getAmpliTypeAvail                   |
| ncCamGetFreqAvail                        | getFreqAvail                        |
| ncCamSetExposureTime                     | setExposureTime                     |
| ncCamGetExposureTime                     | getExposureTime                     |
| ncCamSetWaitingTime                      | setWaitingTime                      |
| ncCamGetWaitingTime                      | getWaitingTime                      |
| ncCamSetTriggerMode                      | setTriggerMode                      |
| ncCamGetTriggerMode                      | getTriggerMode                      |
| ncCamSetShutterMode                      | setShutterMode                      |
| ncCamGetShutterMode                      | getShutterMode                      |
| ncCamSetShutterPolarity                  | setShutterPolarity                  |
| ncCamGetShutterPolarity                  | getShutterPolarity                  |
| ncCamSetExternalShutter                  | setExternalShutter                  |
| ncCamGetExternalShutter                  | getExternalShutter                  |
| ncCamSetExternalShutterMode              | setExternalShutterMode              |
| ncCamGetExternalShutterMode              | getExternalShutterMode              |
| ncCamSetExternalShutterDelay             | setExternalShutterDelay             |
| ncCamGetExternalShutterDelay             | getExternalShutterDelay             |
| ncCamSetFirePolarity                     | setFirePolarity                     |
| ncCamGetFirePolarity                     | getFirePolarity                     |
| ncCamSetOutputMinimumPulseWidth          | setOutputMinimumPulseWidth          |
| ncCamGetOutputMinimumPulseWidth          | getOutputMinimumPulseWidth          |
| ncCamSetArmPolarity                      | setArmPolarity                      |
| ncCamGetArmPolarity                      | getArmPolarity                      |
| ncCamSetCalibratedEmGain                 | setCalibratedEmGain                 |
| ncCamGetCalibratedEmGain                 | getCalibratedEmGain                 |
| ncCamGetCalibratedEmGainRange            | getCalibratedEmGainRange            |
| ncCamGetCalibratedEmGainTempRange        | getCalibratedEmGainTempRange        |
| ncCamSetRawEmGain                        | setRawEmGain                        |
| ncCamGetRawEmGain                        | getRawEmGain                        |
| ncCamGetRawEmGainRange                   | getRawEmGainRange                   |
| ncCamSetAnalogGain                       | setAnalogGain                       |
| ncCamGetAnalogGain                       | getAnalogGain                       |
| ncCamGetAnalogGainRange                  | getAnalogGainRange                  |
| ncCamSetAnalogOffset                     | setAnalogOffset                     |
| ncCamGetAnalogOffset                     | getAnalogOffset                     |
| ncCamGetAnalogOffsetRange                | getAnalogOffsetRange                |
| ncCamSetTargetDetectorTemp               | setTargetDetectorTemp               |
| ncCamGetDetectorTemp                     | getDetectorTemp                     |
| ncCamGetTargetDetectorTemp               | getTargetDetectorTemp               |
| ncCamGetTargetDetectorTempRange          | getTargetDetectorTempRange          |
| ncCamGetComponentTemp                    | getComponentTemp                    |
| ncCamGetSerialNumber                     | getSerialNumber                     |
| ncCamGetDetectorType                     | getDetectorType                     |
| ncCamDetectorTypeEnumToString            |                                     |
| ncCamSetBinningMode                      | setBinningMode                      |
| ncCamGetBinningMode                      | getBinningMode                      |
| ncCamSetMRoiSize                         | setMRoiSize                         |
| ncCamGetMRoiSize                         | getMRoiSize                         |
| ncCamSetMRoiPosition                     | setMRoiPosition                     |
| ncCamGetMRoiPosition                     | getMRoiPosition                     |
| ncCamGetMRoiCount                        | getMRoiCount                        |
| ncCamGetMRoiCountMax                     | getMRoiCountMax                     |
| ncCamAddMRoi                             |                                     |
| ncCamDeleteMRoi                          |                                     |
| ncCamGetMRoiInputRegion                  | getMRoiInputRegion                  |
| ncCamGetMRoiOutputRegion                 | getMRoiOutputRegion                 |
| ncCamGetMRoiRegionCount                  | getMRoiRegionCount                  |
| ncCamMRoiApply                           |                                     |
| ncCamMRoiRollback                        |                                     |
| ncCamMRoiHasChanges                      |                                     |
| ncCamMRoiCanApplyWithoutStop             |                                     |
| ncCamGetVersion                          | getVersion                          |
| ncCamGetActiveRegion                     | getActiveRegion                     |
| ncCamGetFullCCDSize                      | getFullCCDSize                      |
| ncCamNbrImagesAcquired                   |                                     |
| ncCamGetSafeShutdownTemperature          | getSafeShutdownTemperature          |
| ncCamSetCropMode                         | setCropMode                         |
| ncCamGetCropMode                         | getCropMode                         |
| ncCamCreateBias                          |                                     |
| ncCamCancelBiasCreation                  |                                     |
| ncCamGetProcType                         | getProcType                         |
| ncCamSetProcType                         | setProcType                         |
| ncCamCreateBiasNewImageCallback          |                                     |
| ncCamStatsAddRegion                      |                                     |
| ncCamStatsRemoveRegion                   |                                     |
| ncCamStatsResizeRegion                   |                                     |
| ncCamStatsGetCrossSection                |                                     |
| ncCamStatsGetGaussFit                    |                                     |
| ncCamSetOnStatusAlertCallback            | setOnStatusAlertCallback            |
| ncCamSetOnStatusUpdateCallback           | setOnStatusUpdateCallback           |
| ncCamSetStatusPollRate                   | setStatusPollRate                   |
| ncCamGetStatusPollRate                   | getStatusPollRate                   |
| ncCamSetSerialCarTime                    | setSerialCarTime                    |
| ncCamGetSerialCarTime                    | getSerialCarTime                    |
| ncCamParamSupportedInt                   | supportedParamInt                   |
| ncCamParamSupportedDbl                   | supportedParamDbl                   |
| ncCamParamSupportedStr                   | supportedParamStr                   |
| ncCamParamSupportedVoidPtr               | supportedParamVoidPtr               |
| ncCamParamSupportedCallback              | supportedParamCallback              |
| ncCamParamGetCountInt                    | getParamCountInt                    |
| ncCamParamGetCountDbl                    | getParamCountDbl                    |
| ncCamParamGetCountStr                    | getParamCountStr                    |
| ncCamParamGetCountVoidPtr                | getParamCountVoidPtr                |
| ncCamParamGetCountCallback               | getParamCountCallback               |
| ncCamParamGetNameInt                     | getParamNameInt                     |
| ncCamParamGetNameDbl                     | getParamNameDbl                     |
| ncCamParamGetNameStr                     | getParamNameStr                     |
| ncCamParamGetNameVoidPtr                 | getParamNameVoidPtr                 |
| ncCamParamGetNameCallback                | getParamNameCallback                |
| ncCamParamSetInt                         | setParamInt                         |
| ncCamParamSetDbl                         | setParamDbl                         |
| ncCamParamSetStr                         | setParamStr                         |
| ncCamParamSetVoidPtr                     | setParamVoidPtr                     |
| ncCamParamSetCallback                    | setParamCallback                    |
| ncCamParamUnsetInt                       | unsetParamInt                       |
| ncCamParamUnsetDbl                       | unsetParamDbl                       |
| ncCamParamUnsetStr                       | unsetParamStr                       |
| ncCamParamUnsetVoidPtr                   | unsetParamVoidPtr                   |
| ncCamParamUnsetCallback                  | unsetParamCallback                  |
| ncCamParamGetInt                         | getParamInt                         |
| ncCamParamGetDbl                         | getParamDbl                         |
| ncCamParamGetStr                         | getParamStr                         |
| ncCamParamGetStrSize                     | getParamStrSize                     |
| ncCamParamGetVoidPtr                     | getParamVoidPtr                     |
| ncCamParamGetCallback                    | getParamCallback                    |

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncCropModeSolutionsOpen                  |                                     |
| ncCropModeSolutionsRefresh               |                                     |
| ncCropModeSolutionsSetParameters         |                                     |
| ncCropModeSolutionsGetParameters         |                                     |
| ncCropModeSolutionsGetTotal              |                                     |
| ncCropModeSolutionsGetResult             |                                     |
| ncCropModeSolutionsGetLocationRanges     |                                     |
| ncCropModeSolutionsGetResultAtLocation   |                                     |
| ncCropModeSolutionsClose                 |                                     |

### Processing Functions

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncProcOpen                               | open                                |
| ncProcClose                              | close                               |
| ncProcResize                             | resize                              |
| ncProcAddBiasImage                       | addBiasImage                        |
| ncProcComputeBias                        | computeBias                         |
| ncProcSetProcType                        | setType                             |
| ncProcGetProcType                        | getType                             |
| ncProcProcessDataImageInPlace            | processDataImageInPlace             |
| ncProcProcessDataImageInPlaceForceType   | processDataImageInPlaceForceType    |
| ncProcGetImage                           | getImage                            |
| ncProcAddDataImage                       | addDataImage                        |
| ncProcReleaseImage                       | releaseImage                        |
| ncProcEmptyStack                         | emptyStack                          |
| ncProcSetBiasClampLevel                  | setBiasClampLevel                   |
| ncProcGetBiasClampLevel                  | getBiasClampLevel                   |
| ncProcSetOverscanLines                   | setOverscanLines                    |
| ncProcGetOverscanLines                   | getOverscanLines                    |
| ncProcSave                               | save                                |
| ncProcLoad                               | load                                |
| ncProcSaveSetHeaderCallback              | setSaveHeaderCallback               |
| ncProcLoadSetHeaderCallback              | setLoadHeaderCallback               |

### Statistical Functions

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncStatsOpen                              | open                                |
| ncStatsClose                             | close                               |
| ncStatsResize                            | resize                              |
| ncStatsAddRegion                         | addRegion                           |
| ncStatsRemoveRegion                      | removeRegion                        |
| ncStatsResizeRegion                      | resizeRegion                        |
| ncStatsGetHistoCrossSection              | getHistoCrossSection                |
| ncStatsGetGaussFit                       | getGaussFit                         |



## Deprecated Functions

Deprecated functions are not interfaced.

| Deprecated C Function            | Non-deprecated Alternative      |
| :------------------------------- | :------------------------------ |
| ncGrabOpenUnlock                 |                                 |
| ncGrabReadTimed                  |                                 |
| _ncGrabNbrImagesAcquired         |                                 |
| ncCamOpenUnlock                  |                                 |
| ncCamReadTimed                   |                                 |
| ncCamReadUInt32Timed             |                                 |
| ncCamReadFloatTimed              |                                 |
| ncCamGetEmRawGainMin             |                                 |
| ncCamGetEmRawGainMax             |                                 |
| ncCamGetAnalogGainMin            |                                 |
| ncCamGetAnalogGainMax            |                                 |
| ncCamGetAnalogOffsetMin          |                                 |
| ncCamGetAnalogOffsetMax          |                                 |
| ncCamGetTargetDetectorTempMin    |                                 |
| ncCamGetTargetDetectorTempMax    |                                 |
| ncCamGetControllerTemp           |                                 |
| ncCamGetBinningModesAvailable    |                                 |
| ncCamSetRoi                      |                                 |
| ncCamMoveRoi                     |                                 |
| ncCamGetRoi                      |                                 |
| ncCamGetRoisAvailable            |                                 |
| ncProcGetOneImage                |                                 |
| ncCamGetCameraPresent            |                                 |
| ncCamGetCameraAvailable          | ncControllerListGetSize         |
| ncCamGetCameraPort               | (a)                             |
| ncCamGetCameraCommInterface      | (b)                             |
| ncCamGetCameraMacAddress         | ncControllerListGetUniqueID     |
| ncCamGetCameraSerialNumber       | ncControllerListGetSerial       |
| ncCamGetCameraDetectorSize       | ncControllerListGetDetectorSize |
| ncCamGetCameraDetectorType       | ncControllerListGetDetectorType |
| ncGrabGetControllerAvailable     | ncControllerListGetSize         |
| ncGrabGetControllerSerialNumber  | ncControllerListGetSerial       |
| ncGrabGetControllerPort          | (a)                             |
| ncGrabGetControllerCommInterface | (b)                             |
| ncGrabGetControllerMacAddress    | ncControllerListGetUniqueID     |
| ncGrabGetControllerPresent       |                                 |

(a) Use `ncControllerListGetPortChannel`, `ncGrabOpenFromList` or `ncCamOpenFromList`.

(b) Use `ncControllerListGetPortInterface`, `ncGrabOpenFromList` or `ncCamOpenFromList`.
