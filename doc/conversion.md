## Interfaced Functions

The following table lists the interfaced C functions of the Nüvü Camēras SDK
and the corresponding Julia methods.

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncWriteFileHeader                        |                                     |
| ncReadFileHeader                         |                                     |
| ncImageGetFileFormat                     |                                     |
| ncControllerListOpen                     |                                     |
| ncControllerListOpenBasic                |                                     |
| ncControllerListFree                     |                                     |
| ncControllerListGetSize                  |                                     |
| ncControllerListGetSerial                |                                     |
| ncControllerListGetModel                 |                                     |
| ncControllerListGetPortUnit              |                                     |
| ncControllerListGetPortChannel           |                                     |
| ncControllerListGetPortInterface         |                                     |
| ncControllerListGetUniqueID              |                                     |
| ncControllerListGetFullSizeSize          |                                     |
| ncControllerListGetDetectorSize          |                                     |
| ncControllerListGetDetectorType          |                                     |
| ncControllerListGetFreePortCount         |                                     |
| ncControllerListGetFreePortUnit          |                                     |
| ncControllerListGetFreePortChannel       |                                     |
| ncControllerListGetFreePortInterface     |                                     |
| ncControllerListGetFreePortUniqueID      |                                     |
| ncControllerListGetFreePortReason        |                                     |
| ncControllerListGetPluginCount           |                                     |
| ncControllerListGetPluginName            |                                     |

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

| C Function                               | Julia Method                        |
| :--------------------------------------- | :---------------------------------- |
| ncGrabOpenUnlock                         |                                     |
| ncGrabReadTimed                          |                                     |
| _ncGrabNbrImagesAcquired                 |                                     |
| ncCamOpenUnlock                          |                                     |
| ncCamReadTimed                           |                                     |
| ncCamReadUInt32Timed                     |                                     |
| ncCamReadFloatTimed                      |                                     |
| ncCamGetEmRawGainMin                     | getEmRawGainMin                     |
| ncCamGetEmRawGainMax                     | getEmRawGainMax                     |
| ncCamGetAnalogGainMin                    | getAnalogGainMin                    |
| ncCamGetAnalogGainMax                    | getAnalogGainMax                    |
| ncCamGetAnalogOffsetMin                  | getAnalogOffsetMin                  |
| ncCamGetAnalogOffsetMax                  | getAnalogOffsetMax                  |
| ncCamGetTargetDetectorTempMin            | getTargetDetectorTempMin            |
| ncCamGetTargetDetectorTempMax            | getTargetDetectorTempMax            |
| ncCamGetControllerTemp                   | getControllerTemp                   |
| ncCamGetBinningModesAvailable            | getBinningModesAvailable            |
| ncCamSetRoi                              | setRoi                              |
| ncCamMoveRoi                             |                                     |
| ncCamGetRoi                              | getRoi                              |
| ncCamGetRoisAvailable                    | getRoisAvailable                    |
| ncProcGetOneImage                        |                                     |
| ncCamGetCameraPresent                    | getCameraPresent                    |
| ncCamGetCameraAvailable                  | getCameraAvailable                  |
| ncCamGetCameraPort                       | getCameraPort                       |
| ncCamGetCameraCommInterface              | getCameraCommInterface              |
| ncCamGetCameraMacAddress                 | getCameraMacAddress                 |
| ncCamGetCameraSerialNumber               | getCameraSerialNumber               |
| ncCamGetCameraDetectorSize               | getCameraDetectorSize               |
| ncCamGetCameraDetectorType               | getCameraDetectorType               |
| ncGrabGetControllerAvailable             | getControllerAvailable              |
| ncGrabGetControllerSerialNumber          | getControllerSerialNumber           |
| ncGrabGetControllerPort                  | getControllerPort                   |
| ncGrabGetControllerCommInterface         | getControllerCommInterface          |
| ncGrabGetControllerMacAddress            | getControllerMacAddress             |
| ncGrabGetControllerPresent               | getControllerPresent                |
