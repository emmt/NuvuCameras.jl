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
