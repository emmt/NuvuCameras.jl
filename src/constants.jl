#
# constants.jl -
#
# Constants defined for Nüvü Camēras.
#
# *DO NOT EDIT* Some parts of this file are generated automatically.
#
const OPENGL_ENABLE  = Cint(0)

const NC_AUTO_DETECT    = Cint(0x0000ffff)
const NC_AUTO_CHANNEL   = NC_AUTO_DETECT
const NC_AUTO_UNIT	= Cint(0x6fffffff)
const NC_FULL_WIDTH     = Cint(-1)
const NC_FULL_HEIGHT    = Cint(-1)
const NC_USE_MAC_ADRESS = Cint(0x20000000)

# Type of amplifier set by the seleted readout mode.
@enum(Ampli::Cint, NOTHING = 0, EM, CONV)

# Type of communication interface that can be used.
@enum(CommType::Cint,
      INVALID     = 0x0000fffe,
      AUTO_COMM   = 0x6fff0000, # NC_AUTO_UNIT - NC_AUTO_DETECT
      VIRTUAL     = 0x7fff0000,
      EDT_CL      = 0x00000000,
      PT_GIGE     = 0x00010000,
      MIL_CL      = 0x00020000,
      SAPERA_CL   = 0x00030000,
      UNKNOWN     = 0x00040000,
      REMOTE_COMM = 0x00050000)

@enum(DetectorType::Cint,
      CCD60 = 0,
      CCD97,
      CCD201_20,
      CCD207_00,
      CCD207_10,
      CCD207_40,
      CCD220,
      UNKNOWN_CCD)

# All camera parameters.
@enum(Features::Cint,
      UNKNOWN_FEATURE,
      EXPOSURE,
      WAITING_TIME,
      TRIGGER_MODE,
      SHUTTER_MODE,
      SHUTTER_POLARITY,
      EXTERNAL_SHUTTER,
      EXTERNAL_SHUTTER_MODE,
      EXTERNAL_SHUTTER_DELAY,
      FIRE_POLARITY,
      MINIMUM_PULSE_WIDTH,
      ARM_POLARITY,
      CALIBRATED_EM_GAIN,
      RAW_EM_GAIN,
      ANALOG_GAIN,
      ANALOG_OFFSET,
      TARGET_DETECTOR_TEMP,
      DETECTOR_TEMP,
      CTRL_TIMESTAMP,
      GPS_PRESENT,
      GPS_LOCKED,
      BINNING_X,
      BINNING_Y,
      ROI,
      CROP_MODE_X,
      CROP_MODE_Y,
      ACTIVE_REGION,
      MULTIPLE_ROI,
      TRIGGER_MODE_INTERNAL,   # INTERNAL trigger mode
      TRIGGER_MODE_EXTERNAL,   # EXT_HIGH_LOW or EXT_LOW_HIGH
      TRIGGER_MODE_EXPOSURE,   # EXT_HIGH_LOW_EXP or EXT_HIGH_LOW_EXP
      TRIGGER_MODE_CONTINUOUS, # CONT_HIGH_LOW or CONT_LOW_HIGH
      SYSTEM_STATUS,
      SHORT_SSVA_CMD,
      BIN_CDS)

# For backwards compatibiliy
const Param = Features

# List of different temperatures
@enum(NcTemperatureType::Cint,
      NC_TEMP_CCD,
      NC_TEMP_CONTROLLER,
      NC_TEMP_POWER_SUPPLY,
      NC_TEMP_FPGA,
      NC_TEMP_HEATINK)

# Reasons why a tap was reported as unused
@enum(NcPortUnusedReason::Cint,
      NC_PORT_UNUSED_NO_DEVICE,      # The port was found to not be connected to a device
      NC_PORT_UNUSED_ALREADY_IN_USE, # The device is already in use by another instance
      NC_PORT_UNUSED_FILTERED,       # Port was not scanned (filtered, internal use only)
      NC_PORT_UNUSED_UNKNOWN)        # The reason was unusual and has no unique identifier

# Type of shutter mode available
@enum(ShutterMode::Cint, SHUT_NOT_SET = 0, OPEN = 1, CLOSE = 2, AUTO = 3)
const BIAS_DEFAULT = CLOSE

# Type of trigger mode available
@enum(TriggerMode::Cint,
      CONT_HIGH_LOW = -3,
      EXT_HIGH_LOW_EXP = -2,
      EXT_HIGH_LOW = -1,
      INTERNAL = 0,
      EXT_LOW_HIGH = 1,
      EXT_LOW_HIGH_EXP = 2,
      CONT_LOW_HIGH = 3)

# Type of crop-mode available
@enum(CropMode::Cint,
      CROP_MODE_DISABLE = 0,
      CROP_MODE_ENABLE_X = 1,
      CROP_MODE_ENABLE_Y = 2,
      CROP_MODE_ENABLE_XY = 3)
const CROP_MODE_ENABLE_ZL = CROP_MODE_ENABLE_X
const CROP_MODE_ENABLE_SP = CROP_MODE_ENABLE_Y
const CROP_MODE_ENABLE_MX = CROP_MODE_ENABLE_XY

@enum(ExtShutter::Cint, EXTERNAL_SHUTTER_DISABLE = 0, EXTERNAL_SHUTTER_ENABLE = 1)

@enum(ExtPolarity::Cint,NEGATIVE = -1, POL_NOT_SET = 0, POSITIVE = 1)

# Type of image format which will be used to save an image
@enum(ImageFormat::Cint, UNKNOWNN = -1, TIF = 0, FITS)

# Use only CFITSIO DATATYPE codes
@enum(ImageDataType::Cint,
      NC_IMG,       # uint 16 bit
      NC_IMG_UINT,  # uint 32 bit
      NC_IMG_ULONG, # uint 64 bit
      NC_IMG_FLOAT) # 32 bit float

@enum(HeaderDataType::Cint, NC_INT, NC_DOUBLE, NC_STRING)

@enum(ImageCompression::Cint, NO_COMPRESSION = 0, GZIP)

@enum(ProcType::Cint, NO_PROC = 0x00, LM = 0x01, PC = 0x02)

@enum(TimestampMode::Cint,
      NO_TIMESTAMP = 0,
      INTERNAL_TIMESTAMP = 1,
      GPS_TIMESTAMP = 2)

# List of possible version numbers.
@enum(VersionType::Cint, SOFTWARE, FIRMWARE, FPGA, HARDWARE)

# Tiff tags.
@enum(TiffTag::Cint,
      AMPLI_TYPE_TAG           = 650,
      HORIZ_FREQ_TAG           = 651,
      VERT_FREQ_TAG            = 652,
      EXPOSURE_TIME_TAG        = 653,
      EFFECTIVE_EXP_TIME_TAG   = 682,
      WAITING_TIME_TAG         = 654,
      RAW_EM_GAIN_TAG          = 655,
      CAL_EM_GAIN_TAG          = 680,
      ANALOG_GAIN_TAG          = 656,
      ANALOG_OFFSET_TAG        = 657,
      TARGET_DETECTOR_TEMP_TAG = 658,
      BINNING_X_TAG            = 659,
      BINNING_Y_TAG            = 660,
      ROI_X1_TAG               = 661,
      ROI_X2_TAG               = 662,
      ROI_Y1_TAG               = 663,
      ROI_Y2_TAG               = 664,
      CROP_MODE_ENABLE_TAG     = 695,
      CROP_MODE_PADDING_X_TAG  = 696,
      CROP_MODE_PADDING_Y_TAG  = 697,
      SHUTTER_MODE_TAG         = 665,
      TRIGGER_MODE_TAG         = 666,
      CLAMP_LEVEL_TAG          = 667,
      PROC_TYPE_TAG            = 676,
      NBR_PC_IMAGES_TAG        = 675,
      SERIAL_NUMBER_TAG        = 668,
      FIRM_VERSION_TAG         = 669,
      HARDW_VERSION_TAG        = 670,
      FPGA_VERSION_TAG         = 671,
      SOFT_VERSION_TAG         = 672,
      ADD_COMMENTS_TAG         = 674,
      OVERSCAN_LINES_TAG       = 677,
      OVERSAMPLE_X_TAG         = 678,
      DETECTOR_TYPE_TAG        = 681,
      FIRE_POLARITY_TAG        = 688,
      SHUTTER_POLARITY_TAG     = 683,
      ARM_POLARITY_TAG         = 689,
      OUTPUT_PULSE_WIDTH_TAG   = 687,
      EXT_SHUTTER_PRES_TAG     = 684,
      EXT_SHUTTER_MODE_TAG     = 685,
      EXT_SHUTTER_DELAY_TAG    = 686,
      OBS_DATE_TAG             = 690,
      OBS_TIME_SEC_FRACT_TAG   = 691,
      OBS_FLAGS_TAG            = 692,
      DATE_TIME_US_TAG         = 694,
      HOST_TIME_TAG            = 693,
      NBR_IMAGES_TRIG_TAG      = 679,
      SEQUENCE_NAME_TAG        = 673)

# Common data type enumeration
@enum(NcSdkDataTypes::Cint,
      NcSdkDataTypeInt = 0,
      NcSdkDataTypeDouble,
      NcSdkDataTypeString)

# Error codes.
const NC_SUCCESS = Status(0)
const NC_GENERIC_ERROR = Status(1)
const NC_ERROR_MEM_ALLOC = Status(11) # Memory allocation error, please make sure your system have sufficient RAM to operate your application
const NC_ERROR_MUTEX_LOCK = Status(12)
const NC_ERROR_MUTEX_RELEASE = Status(14) # An internal mutex can't be released, please review the concurrent threads of your application
const NC_ERROR_CREATE_THREAD = Status(15) # An internal thread can't be properly created
const NC_ERROR_RELEASE_THREAD = Status(16)
const NC_ERROR_WAIT_SIGNAL = Status(17)
const NC_ERROR_BAD_CMD_LINE_PARAMS = Status(18)
const NC_ERROR_DATA_TYPE = Status(25) # The data type passed for this function is invalid
const NC_ERROR_IMAGE_HEADER_FORMAT = Status(26) # The image format doesn't support additional headers
const NC_ERROR_CAMERA_FOUND = Status(27) # No camera has been found using the automatic parameters passed
const NC_ERROR_NO_GRABBER = Status(28)
const NC_ERROR_UNKNOWN = Status(41)
const NC_ERROR_STL_ERROR = Status(42) # std::exception
const NC_ERROR_LOGIC_ERROR = Status(43) # std::logic_error exception
const NC_ERROR_RUNTIME_ERROR = Status(44) # std::runtime_error exception
const NC_ERROR_BAD_CAST = Status(45) # stdbad_cast exception
const NC_ERROR_BAD_FUNC_POINTER = Status(46) # std::bad_function_call
const NC_ERROR_BAD_TYPE_ID = Status(47) # std::bad_typeid
const NC_ERROR_BAD_WEAK_PTR = Status(48) # std::bad_weak_ptr
const NC_ERROR_COM_CMD_RET = Status(51) # The camera returned an error to the command sent
const NC_ERROR_COM_CMD_ANSW = Status(52) # The camera never finished answering the command sent
const NC_ERROR_COM_CSUM_REC = Status(53) # The checksum calculated for the answer received doesn't match the one sent by the camera
const NC_ERROR_COM_CSUM_SENT = Status(54) # The camera returned an error to the checksum sent
const NC_ERROR_COM_CSUM_ANSW = Status(55) # The camera never finished answering the checksum sent
const NC_ERROR_COM_ABORT_STATE = Status(56) # The camera status command didn't came back in the idle state as it should after an abort
const NC_ERROR_COM_UNEXPECTED = Status(57) # Serial communication with the controller diverged from the established protocol
const NC_ERROR_CAM_PARSE_INIT = Status(76) # One of the passed parameter hasn't been properly initialized
const NC_ERROR_CAM_PARSE_FOUND = Status(77) # The information expected hasn't been found
const NC_ERROR_CAM_PARSE_DEFINE = Status(78) # The internal define function hasn't been able to run as expected
const NC_ERROR_NO_MENS_LAND = Status(99) # You're in an unexpected case, if you can reproduce this issue, contact Nuvu Cameras
const NC_ERROR_CAM_STRUCT_PTR = Status(101) # The structure pointer (NcCam) passed to the function is invalid
const NC_ERROR_CAM_PARAM_INIT = Status(102) # One of the required parameters hasn't been properly initialized
const NC_ERROR_CAM_PARAM_OUT = Status(103) # One of the parameter values is invalid because it is out of bounds
const NC_ERROR_CAM_ASCII_REC = Status(104) # Even though the serial answer received seems fine, a typo error from the controller seems to be present
const NC_ERROR_CAM_FIRMWARE_VERSION = Status(105) # The firmware version of the controller isn't compatible with the feature you're trying to use
const NC_ERROR_CAM_FIRMWARE_DETECTION = Status(106) # The firmware version can't be read properly
const NC_ERROR_CAM_NO_FEATURE = Status(107) # The feature you're looking to use isn't supported by this camera
const NC_ERROR_CAM_NO_READOUT = Status(108) # The readout mode loaded isn't a valid one
const NC_ERROR_CAM_EM_READOUT = Status(109) # This function can only be executed while using an EM readout mode, which isn't the case
const NC_ERROR_CAM_SAVE_OPEN = Status(110) # The file you're trying to create to save the image can't be put in place
const NC_ERROR_CAM_SAVE_FORMAT = Status(111) # The save format specified isn't valid or supported for this data type
const NC_ERROR_CAM_SAVE_OVERWRITE = Status(112) # There's already an image file with this name, please select a new name or modify the overwrite flag
const NC_ERROR_CAM_SAVE_DEPTH = Status(113) # The data type specified can't be saved with the appropriate depth
const NC_ERROR_CAM_INTERNAL_REG = Status(114) # Some internal camera registers hasn't properly be initialized
const NC_ERROR_CAM_PARAM_OPEN = Status(115) # The camera parameter file speified can't be opened
const NC_ERROR_CAM_PARAM_READ = Status(116) # The camera parameter file can't be read properly, please make sure it's not write protected and you have the rights to access this file
const NC_ERROR_CAM_PARAM_POS = Status(117) # The camera parameter file size can't be retrieved, make sure it's not empty
const NC_ERROR_CAM_PARAM_VALUE = Status(118) # The buffer size in which the camera parameter file information are being copied isn't the appropriate one
const NC_ERROR_CAM_PARAM_READOUT = Status(119) # There's no readout mode matching the one you used when saving your parameters
const NC_ERROR_CAM_PARAM_MISS = Status(120) # Some required camera parameters can't be found in the camera parameters file
const NC_ERROR_CAM_PARAM_OVERWRITE = Status(121) # There's already a camera parameter file existing with the same name, please select a new name or modify the overwrite flag
const NC_ERROR_CAM_EMPTY_ANSWER = Status(122)
const NC_ERROR_CAM_FEATURE_DISABLED = Status(123) # The current mode of operation means that this function can't be used (e.g. Crop mode prohibits MoveRoi)
const NC_ERROR_CAM_ROI_OVERLAP = Status(124) # Can't apply the current ROIs because two or more ROIs overlap
const NC_ERROR_CAM_TOO_MANY_ROIS = Status(125) # Trying to add an ROI, but the maximum number of supported ROIs has been reached
const NC_ERROR_CAM_BAD_ROI_INDEX = Status(126) # Trying to access an ROI, but the index that was used is invalid
const NC_ERROR_CAM_ROI_OUT_OF_BOUNDS = Status(127) # An ROI's definition exceeds the available dimensions of the sensor
const NC_ERROR_CAM_SAVE_WRITE_DATA = Status(128) # An error occured while writing pixel values to an image file
const NC_ERROR_CAM_SAVE_WRITE_META = Status(129) # An error occured while writing metadata to an image file
const NC_ERROR_CAM_DEPRECATED = Status(130) # This function is deprecated and this use of it is not supported
const NC_ERROR_CAM_NONSTOP = Status(131) # The acquisition in progress is required to not halt but the change requested would require it
const NC_ERROR_CAM_NO_READOUT_MODE = Status(132) # No readout sequence has been loaded yet
const NC_ERROR_CAM_READOUT_MODE_INVALID = Status(133) # The selected readout mode does not conform to the requirements of a CamContext
const NC_ERROR_CAM_ROI_INVLAID = Status(134) # The requested ROI cannot be returned
const NC_ERROR_CAM_CROPMODE_ROI_INVLAID = Status(135) # The requested ROI cannot be returned with this crop-mode
const NC_ERROR_CAM_NOT_PREPARED = Status(136) # The user has asked the acquisition to begin but has not prepared the framegrabber
const NC_ERROR_CAM_NO_ROIS = Status(137) # Trying to apply ROIs, but none are defined; there must always be one or more ROIs defined.
const NC_ERROR_GRAB_STRUCT_PTR = Status(201) # The structure pointer (NcGrab) passed to the function is invalid
const NC_ERROR_GRAB_PARAM_INIT = Status(202) # One of the required parameter hasn't been properly initialized
const NC_ERROR_GRAB_PARAM_OUT = Status(203) # One of the parameter value is out of bound and can't be used
const NC_ERROR_GRAB_REG_ACCESS = Status(204) # The nc registry keys can't be accessed. Please make sure that the installation of this software does not report an error and that the permissions of your current session let you access the registry of your system.
const NC_ERROR_GRAB_REG_MISS = Status(205) # Some of the mandatory nc registry keys haven't been setup properly. Please contact nc Technical support to remedy this issue.
const NC_ERROR_GRAB_COMM_INTER = Status(206) # Unknown communication interface passed to the Open function thru the Unit parameter
const NC_ERROR_GRAB_CONFIG_OPEN = Status(207) # The Nuvu Cameras configuration file can't be opened, please make sure it's in the Nuvu Cameras path
const NC_ERROR_GRAB_CONFIG_READ = Status(208) # The Nuvu Cameras configuration file can't be read properly, please make sure it's not right protected and you have the rights to access this file
const NC_ERROR_GRAB_CONFIG_POS = Status(209) # The Nuvu Cameras configuration file size can't be retrieved, make sure it's not empty
const NC_ERROR_GRAB_CONFIG_VALUE = Status(210) # The buffer size in which the Nuvu Cameras configuration file information are being copied isn't the appropriate one
const NC_ERROR_GRAB_LOG_OPEN = Status(211) # The log file file can't be opened, please make sure "Log" folder exist in the Nuvu Cameras path
const NC_ERROR_GRAB_SAVE_FORMAT = Status(212) # The save format specified isn't valid or supported
const NC_ERROR_GRAB_COMP_FORMAT = Status(213) # The compression format specified isn't valid or supported
const NC_ERROR_GRAB_TIMEOUT = Status(214) # The image didn't arrived prior to the timeout value set
const NC_ERROR_GRAB_NO_IMAGE = Status(215) # There's no image already available, so a null pointer is being returned
const NC_ERROR_GRAB_NOT_STOP = Status(216) # Acquisitions are still in progress even though they should be stopped
const NC_ERROR_GRAB_CLOSE_ACQUISITION = Status(217)
const NC_ERROR_GRAB_SKIP_IMAGE = Status(218)
const NC_ERROR_GRAB_BIAS_SIZE = Status(219)
const NC_ERROR_GRAB_DEBUG_LEVEL = Status(220)
const NC_ERROR_GRAB_PROC_TIMEOUT = Status(221)
const NC_ERROR_GRAB_BIAS_CANCEL = Status(222)
const NC_ERROR_GRAB_SUPPORT_MAC = Status(223)
const NC_ERROR_GRAB_FIRMWARE_VERSION = Status(224)
const NC_ERROR_GRAB_NO_FEATURE = Status(225) # The feature you're looking to use isn't supported by this controller
const NC_ERROR_GRAB_NO_GPS = Status(226)
const NC_ERROR_GRAB_TIMESTAMP_SKIP = Status(227)
const NC_ERROR_GRAB_GPS_UNLOCK = Status(228)
const NC_ERROR_GRAB_NO_TIMESTAMP = Status(229)
const NC_ERROR_GRAB_UNMATCH_IMAGE = Status(230)
const NC_ERROR_GRAB_BUFFER_TOO_SMALL = Status(231)
const NC_ERROR_ALREADY_OPENED = Status(232)
const NC_ERROR_GRAB_CONFIRM_FAILED = Status(233)
const NC_ERROR_GRAB_GPS_INVALID = Status(234) # Timestamp information received from the GPS unit is not valid: it must provide the NEMA GPZDA sentence
const NC_ERROR_PROC_STRUCT_PTR = Status(301) # The structure pointer (NcProcCtx) passed to the function is invalid
const NC_ERROR_PROC_PARAM_INI = Status(302) # One of the required parameter hasn't been properly initialized
const NC_ERROR_PROC_PARAM_OUT = Status(303) # One of the parameter value is out of bound and can't be used
const NC_ERROR_PROC_NO_TYPE = Status(304) # The processing type isn't valid or supported
const NC_ERROR_PROC_NO_BIAS = Status(305) # There's no image stored to calculate the Bias
const NC_ERROR_PROC_SAVE_OPEN = Status(306) # The bias file can't be correctly open
const NC_ERROR_PROC_BIAS_LOAD = Status(307) # One the bias parameter can't be loaded correctly
const NC_ERROR_PROC_BIAS_SAVE = Status(308) # There's no Bias image available to save
const NC_ERROR_PROC_SAVE_OVERWRITE = Status(309) # There's already a bias file with this name, please select a new name or modify the overwrite flag
const NC_ERROR_PROC_LOAD_SN = Status(310)
const NC_ERROR_PROC_LOAD_READOUT = Status(311)
const NC_ERROR_PROC_LOAD_AMPLI = Status(312)
const NC_ERROR_PROC_LOAD_VERT = Status(313)
const NC_ERROR_PROC_LOAD_HORIZ = Status(314)
const NC_ERROR_PROC_IMAGE_CONTEXT_SIZE = Status(315) # The number of images the context can contain is 3 or 10
const NC_ERROR_PROC_RETRIEVE_OUT = Status(316) # The number of the image to be retrieved is larger than the maximum number of images that the context stores
const NC_ERROR_PROC_RETRIEVE_LARGE = Status(317) # The number of the image to be retrieved is larger than the number of images in the context
const NC_ERROR_PROC_SIZE_COSMICRAY = Status(318) # The number of images in the context is not large enough for removing cosmic rays. Please add more images
const NC_ERROR_PROC_NO_CONTEXT_SIZE = Status(319) # It is not possible to add / get images to / from the context since it is set to not store images
const NC_ERROR_PROC_NO_RECENT_IMAGE = Status(320) # No more recent images to retrieve
const NC_ERROR_PROC_SIZE_PC = Status(321) # The number of images in the context is not large enough to obtain a PC image. Please add more images
const NC_ERROR_PROC_BAD_MODE = Status(322) # The current processing mode is invalid for the requested operation
const NC_ERROR_EDT_DEP_STRUCT = Status(401) # The internal dependent structure that EDT generates to initialize the frame grabber hasn't been created properly
const NC_ERROR_EDT_INIT = Status(402) # The initialization of the frame grabber failed
const NC_ERROR_EDT_READ_CONFIG = Status(403) # The EDT initialization file hasn't been read properly
const NC_ERROR_EDT_OPEN_STRUCT = Status(404) # The EDT driver hasn't been able to properly open/allocate its structure
const NC_ERROR_EDT_CLOSE_STRUCT = Status(405) # The EDT driver hasn't been able to properly close/free its structure
const NC_ERROR_EDT_MULTIBUF = Status(406) # The EDT driver hasn't been able to allocate the desired number of loop buffer
const NC_ERROR_EDT_SET_BAUD = Status(407) # The EDT driver can't set this baudrate.
const NC_ERROR_EDT_BIN_CMD = Status(408) # The binary command can't be sent using the EDT driver
const NC_ERROR_EDT_SET_TIMEOUT = Status(409) # The timeout can't be set using the the EDT driver
const NC_ERROR_EDT_STOP_BUFFERS = Status(410) # The EDT drivers can't have the buffer to stop receiving images
const NC_ERROR_EDT_PARAM_SIZE = Status(411) # The EDT driver hasn't been able to set the width or the heigth passed in parameter
const NC_ERROR_EDT_SET_SIZE = Status(412) # The EDT driver hasn't been able to modifiy the buffer size receiving the image
const NC_ERROR_EDT_SET_ROI = Status(413) # The EDT driver hasn't been able to modify the buffer size so it size is now matching the buffer receive
const NC_ERROR_EDT_CANCEL_EVENT = Status(414) # The EDT driver can't cancel the grab event linked to the structure passed in parameter
const NC_ERROR_EDT_SET_EVENT = Status(415) # The EDT driver isn't able to properly set the grab event
const NC_ERROR_EDT_DEVICE_FOUND = Status(416) # No device linked through EDT have been found, make sure the cable are correctly plus and try to reboot the device
const NC_ERROR_VIRTUAL_NO_CAMERA = Status(501) # There's no virtual camera specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_DETECTOR_TYPE = Status(502) # There's no detector type specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_DETECTOR_WIDTH = Status(503) # There's no detector width specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_DETECTOR_HEIGHT = Status(504) # There's no detector height specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_TEMP_MIN = Status(505) # There's no minimal temperature specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_TEMP_MAX = Status(506) # There's no maximal temperature specified in the Nuvu Cameras configuration file
const NC_ERROR_VIRTUAL_ACTIVE_WIDTH = Status(507)
const NC_ERROR_VIRTUAL_ACTIVE_HEIGHT = Status(508)
const NC_ERROR_PLEORA_SIZE_MISMATCH = Status(601)
const NC_ERROR_PLEORA_TIMEOUT_MISMATCH = Status(602)
const NC_ERROR_PLEORA_FIND_SYSEM = Status(603) # The Pleora driver hasn't been able to proceed with the detection of the GigE devices
const NC_ERROR_PLEORA_CONNECTION_FAILED = Status(604) # The connection to the requested GigE device failed
const NC_ERROR_PLEORA_DEVICE_FOUND = Status(605) # No GigE device have been found, make sure the cable are correctly plus and try to reboot the device
const NC_ERROR_PLEORA_STREAM_OPEN = Status(606) # The Pleora GigE stream can't be opened with the requested device
const NC_ERROR_PLEORA_STREAM_DESTINATION = Status(607) # The Pleora GigE stream destination can't be set
const NC_ERROR_PLEORA_PIPELINE_BUFFERS = Status(608) # The Pleora acquisitions buffers can't be allocated by the pleora driver
const NC_ERROR_PLEORA_SET_TIMEOUT = Status(609) # The modification request, to have the timeout modified, failed
const NC_ERROR_PLEORA_SET_DEPTH = Status(610) # The modification request, to have the pixel depth modified, failed
const NC_ERROR_PLEORA_DVAL_ENABLE = Status(611) # The modification request, to have the DVAL signal enable, failed
const NC_ERROR_PLEORA_SET_WIDTH = Status(612) # The modification request, to have the image width modified, failed
const NC_ERROR_PLEORA_SET_HEIGHT = Status(613) # The modification request, to have the image height modified, failed
const NC_ERROR_PLEORA_SET_BAUDRATE = Status(614) # The modification request, to have the serial baudrate modified, failed
const NC_ERROR_PLEORA_STOP_BITS = Status(615) # The modification request, to have the number of stop bits set to one, failed
const NC_ERROR_PLEORA_TEST_IMAGE = Status(616) # The modification request, to have the test image disabled, failed
const NC_ERROR_PLEORA_TICK_FREQUENCY = Status(617) # The modification request, to get the tick frequency per second, failed
const NC_ERROR_PLEORA_SET_PARITY = Status(618) # The modification request, to have the parity set to none, failed
const NC_ERROR_PLEORA_RESET_TIMSTAMP = Status(619) # The modification request, to reset the timestamp, failed
const NC_ERROR_PLEORA_SET_LOOPBACK = Status(620) # The modification request, to disable the Uart loopback, failed
const NC_ERROR_PLEORA_ACQUISITION_START = Status(621) # The command, to have the acquisition started, failed
const NC_ERROR_PLEORA_ACQUISITION_STOP = Status(622) # The command, to have the acquisotion stopped, failed
const NC_ERROR_PLEORA_PORT_OPEN = Status(623) # The Pleora GigE port can't be opened with the requested device
const NC_ERROR_PLEORA_SERIAL_SIZE = Status(624) # The Pleora GigE driver can't set the serial buffer size
const NC_ERROR_PLEORA_PIPELINE_START = Status(625) # The Pleora GigE driver can't have the image pipeline to start
const NC_ERROR_PLEORA_SERIAL_WRITE = Status(626) # The Pleora GigE driver can't write the requested command to the serial port
const NC_ERROR_PLEORA_SET_HEARTBEAT = Status(627)
const NC_ERROR_PLEORA_SET_DEVICE = Status(628)
const NC_ERROR_PLEORA_SET_PORT = Status(629)
const NC_ERROR_PLEORA_NEGOCIATE_PACKET = Status(630)
const NC_ERROR_PLEORA_NOT_SUPPORTED = Status(631)
const NC_ERROR_PLEORA_REQUEST_TIMEOUT = Status(632) # The modification request, to set the timeout on an image request, failed
const NC_ERROR_SERVICE_WINSOCK_START = Status(701) # The winsock library hasn't started properly
const NC_ERROR_SERVICE_WINSOCK_VERSION = Status(702) # The winsock version used in the dll isn't the one expected
const NC_ERROR_SERVICE_CREATE_SOCKET = Status(703) # The application hasn't been able to create a socket to connect to the service
const NC_ERROR_SERVICE_CONNECT_SERVICE = Status(704) # The application hasn't been able to connect itself to the service
const NC_ERROR_SERVICE_SEND_COMMAND = Status(705) # The application hasn't been able to send a command to the service
const NC_ERROR_SERVICE_RECEIVE_COMMAND = Status(706) # The application hasn't been able to receive the answer from the service
const NC_ERROR_SERVICE_DEVICE_LOCK = Status(707) # The device you're trying to open is already locked by another application
const NC_ERROR_SERVICE_LOCK_ACCESS_DENIED = Status(708) # The device lock you're trying to access belongs to another process
const NC_ERROR_STATS_INVALID_INDEX = Status(801)
const NC_ERROR_STATS_REGION_OUT = Status(802) # The statsCtx selected is outside the boundaries of the image
const NC_ERROR_STATS_IMAGE_SIZE = Status(803)
const NC_ERROR_STATS_STRUCT_PTR = Status(804)
const NC_ERROR_MIL_DEVICE_FOUND = Status(901)
const NC_ERROR_MIL_NOT_SUPPORTED = Status(902)
const NC_ERROR_MIL_SET_SIZE = Status(903)
const NC_ERROR_MIL_BUFFER_ALLOCATION = Status(904) # Use the MILConfig tool to reserve additional non-paged memory
const NC_ERROR_MIL_UART_UAVAILABLE = Status(905)
const NC_ERROR_APPLICATION_ALLOCATION = Status(906)
const NC_ERROR_MIL_SMALL_WIDTH = Status(907)
const NC_ERROR_MIL_PORT_UNAVAILABLE = Status(908)
const NC_ERRROR_SAPERA_SERIAL_FUNCTION = Status(1001)
const NC_ERROR_SAPERA_SERIAL_READ = Status(1002)
const NC_ERROR_SAPERA_SERIAL_WRITE = Status(1003)
const NC_ERROR_SAPERA_SERIAL_UNREAD = Status(1004)
const NC_ERROR_SAPERA_DEVICE_FOUND = Status(1005)
const NC_ERROR_SAPERA_INVALID_BAUDRATE = Status(1006)
const NC_ERROR_SAPERA_SET_BAUDRATE = Status(1007)
const NC_ERROR_SAPERA_CREATE_ACQUISITION = Status(1008)
const NC_ERROR_SAPERA_SERIAL_PORT = Status(1009)
const NC_ERROR_SAPERA_SERIAL_INIT = Status(1010)
const NC_ERROR_SAPERA_SERIAL_MATCH = Status(1011)
const NC_ERROR_SAPERA_SERIAL_CLOSE = Status(1012)
const NC_ERROR_SAPERA_ACQ_DESTROY = Status(1013)
const NC_ERROR_SAPERA_NBR_SERIAL = Status(1014)
const NC_ERROR_SAPERA_ACQ_CREATE = Status(1015)
const NC_ERROR_SAPERA_BUFFERS_CREATE = Status(1016)
const NC_ERROR_SAPERA_XFER_CREATE = Status(1017)
const NC_ERROR_SAPERA_DESTROY_XFER = Status(1018)
const NC_ERROR_SAPERA_DESTROY_BUFFERS = Status(1019)
const NC_ERROR_SAPERA_DESTROY_ACQ = Status(1020)
const NC_ERROR_SAPERA_BUFFERS_WIDTH = Status(1021)
const NC_ERROR_SAPERA_BUFFERS_HEIGHT = Status(1022)
const NC_ERROR_SAPERA_ACQ_WIDTH = Status(1023)
const NC_ERROR_SAPERA_CROP_WIDTH = Status(1024)
const NC_ERROR_SAPERA_ACQ_HEIGHT = Status(1025)
const NC_ERROR_SAPERA_CROP_HEIGHT = Status(1026)
const NC_ERROR_SAPERA_GRAB_START = Status(1027)
const NC_ERROR_SAPERA_XFER_FREEZE = Status(1028)
const NC_ERROR_SAPERA_XFER_WAIT = Status(1029)
const NC_ERROR_SAPERA_XFER_ABORT = Status(1030)
const NC_ERROR_SAPERA_WIDTH_OUT = Status(1031)
const NC_ERROR_SAPERA_HEIGHT_OUT = Status(1032)
const NC_ERROR_SAPERA_XFER_INIT = Status(1033)
const NC_ERROR_SAPERA_SERIAL_READ_TIMEOUT = Status(1034)
const NC_ERROR_SAPERA_RESSOURCE_CREATE = Status(1035)
const NC_ERROR_SAPERA_ASSERT_FAILURE = Status(1036)
const NC_ERROR_VERSION_FAILED = Status(2001) # Failed to parse a version string
const NC_ERROR_STRING_CAST_FAILED = Status(2002) # Failed to obtain a value from a string
const NC_ERROR_ENV_VAR_ACCESS_FAILED = Status(2003)
const NC_ERROR_PIPELINE_ERROR = Status(3001)
const NC_ERROR_GLOBAL_MUTEX_CREATE_FAILED = Status(4001) # An error occured while creating a global mutex file, check the lock files directory write permissions
const NC_ERROR_GLOBAL_MUTEX_LOCK_FAILED = Status(4002)
const NC_ERROR_SHARED_MEMORY_CREATE_FAILED = Status(4003)
const NC_ERROR_SHARED_MEMORY_TOO_SMALL = Status(4004)
const NC_ERROR_SHARED_MEMORY_ACCESS_FAILED = Status(4005)
const NC_ERROR_PROCESS_FAILED_TO_FIND_BIN = Status(4006)
const NC_ERROR_PROCESS_FAILED_TO_START_BIN = Status(4007)
const NC_ERROR_PROCESS_FAILED_TO_OPEN_PIPE = Status(4008)
const NC_ERROR_PROCESS_PIPE_IO_ERROR = Status(4009)
const NC_ERROR_FAILED_TO_MAKE_DIR = Status(5001)
const NC_ERROR_FAILED_TO_OPEN_FILE = Status(5002)
const NC_ERROR_FAILED_TO_DELETE_FILE = Status(5003)
const NC_ERROR_FILE_IO_FAILED = Status(5004)
const NC_ERROR_FAILED_TO_LOAD_PLUGIN = Status(6001)
const NC_ERROR_FAILED_TO_LOAD_SYMBOL = Status(6002)
const NC_ERROR_SYMBOL_NOT_LOADED = Status(6003)
const NC_ERROR_PLUGIN_DIRECTORY_MISSING = Status(6004)
const NC_ERROR_PLUGIN_METADATA_MISSING = Status(6005)
const NC_ERROR_BOARD_NAME_TOO_LONG = Status(6006)
const NC_ERROR_TAP_TAG_TOO_LONG = Status(6007)
const NC_ERROR_TAP_ALREADY_LOCKED = Status(6008)
const NC_ERROR_PLUGIN_THREW_EXCEPTION = Status(6009)
const NC_ERROR_CORE_OVERFLOW = Status(7001)
const NC_ERROR_CORE_UNDERFLOW = Status(7002)
const NC_ERROR_TIME_CAST_FAILED = Status(7003)
const NC_ERROR_OUT_OF_BOUNDS = Status(7004)
