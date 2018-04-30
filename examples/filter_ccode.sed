#! /bin/sed -f
#
# A small SED script to prepare C to Julia conversion of the examples provided
# by the Nüvü Camēras SDK.
#

# Remove DOS end-of-line marker.
s/\r//

# Repace tabs by ordinary spaces.
s/\t/ /

# Split line at C++ comments if any.  The comment is left in the hold buffer.
/\/\// {h; s/.*\/\/ */# /; x; s/ *\/\/.*//; b code}

# The hold buffer is cleared if there are no comments.
x; s/.*//; x

# Filter C code.
:code

# Remove column at end of lines.
s/ *; *$//

# Remove getting error.
s/\(^ \)*error *= *\(NC_\|nc\|Nc\)/\1\2/

# Prepend output references.
:refs
s/^\([^=]*\)\(=[^&]*(\) *& *\([A-Za-z_][A-Za-z_0-9]*\) *,? */\1, \3\2/
t refs
s/^\([^=]*\)\(=[^&]*([^&)]*\) *, *& *\([A-Za-z_][A-Za-z_0-9]*\) */\1, \3\2/
t refs
s/^\([^&=]*(\) *& *\([A-Za-z_][A-Za-z_0-9]*\) *,? */\2 = \1/
t refs
s/^\([^&=]*([^&=)]*\), *& *\([A-Za-z_][A-Za-z_0-9]*\) */\2 = \1/
t refs

# Rename keywords.
s/\(^\|\([^A-Za-z_0-9]\)\)\(type\|end\|begin\|abstract\)\(\([^A-Za-z_0-9]\)\|$\)/\1_\3\4/g

# Remove prefixes.
s/\([^A-Za-z_0-9]\)\(NC_\|nc\|Nc\)/\1NC./g

# Fix some method names.
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Open(/\1open(NC.\3, /g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Close(/\1close(NC.\3, /g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Start/\1start/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Stop/\1stop/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Abort(/\1abort(/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Set/\1set/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Get/\1get/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)SaveImage\(Ex\|\)\([^A-Za-z_0-9]\)/\1saveImage\5/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)CamSave\(UInt32\|Float\)\([^A-Za-z_0-9]\)/\1saveImage\4/g
s/\(^\|\([^A-Za-z_0-9]\)NC\.\)\(Cam\|Grab\)Read\([^A-Za-z_0-9]\)/\1read\4/g

# # Fix some constant names.
s/\(^\|\([^A-Za-z_0-9]\)\)\(\(OPENGL_ENABLE\|NOTHING\|EM\|CONV\|INVALID\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(AUTO_COMM\|VIRTUAL\|EDT_CL\|PT_GIGE\|MIL_CL\|SAPERA_CL\|UNKNOWN\|REMOTE_COMM\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

# s/\(^\|\([^A-Za-z_0-9]\)\)\(\(CCD\(60\|97\|201\|207_00\|207_10\|207_40\|220\)\|UNKNOWN_CCD\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/
#
# s/\(^\|\([^A-Za-z_0-9]\)\)\(\(ACTIVE_REGION\|ANALOG_\(GAIN\|OFFSET\)\|ARM_POLARITY\|BINNING_[XY]\|BIN_CDS\|CALIBRATED_EM_GAIN\|CROP_MODE_[XY]\|CTRL_TIMESTAMP\|DETECTOR_TEMP\|EXPOSURE\|EXTERNAL_SHUTTER\(\|_DELAY\|_MODE\)\|FIRE_POLARITY\|GPS_\(LOCKED\|PRESENT\)\|MINIMUM_PULSE_WIDTH\|MULTIPLE_ROI\|RAW_EM_GAIN\|ROI\|SHORT_SSVA_CMD\|SHUTTER_\(MODE\|POLARITY\)\|SYSTEM_STATUS\|TARGET_DETECTOR_TEMP\|TRIGGER_MODE\(\|_\(CONTINUOUS\|EXPOSURE\|EXTERNAL\|INTERNAL\)\)\|UNKNOWN_FEATURE\|WAITING_TIME\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

# Shutter mode.
s/\(^\|\([^A-Za-z_0-9]\)\)\(\(SHUT_NOT_SET\|OPEN\|CLOSE\|AUTO\|BIAS_DEFAULT\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(CONT_HIGH_LOW\|EXT_HIGH_LOW_EXP\|EXT_HIGH_LOW\|INTERNAL\|EXT_LOW_HIGH\|EXT_LOW_HIGH_EXP\|CONT_LOW_HIGH\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(CROP_MODE_\(DISABLE\|ENABLE_\([XY]\|XY\|ZL\|SP\|MX\)\)\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(EXTERNAL_SHUTTER_\(DISABLE\|ENABLE\)\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(NEGATIVE\|POL_NOT_SET\|POSITIVE\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

# Image file format.
s/\(^\|\([^A-Za-z_0-9]\)\)\(\(UNKNOWNN\|TIF\|FITS\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(NO_COMPRESSION\|GZIP\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

s/\(^\|\([^A-Za-z_0-9]\)\)\(\(NO_PROC\|LM\|PC\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

# TIFF Tags.
s/\(^\|\([^A-Za-z_0-9]\)\)\(\(AMPLI_TYPE_TAG\|HORIZ_FREQ_TAG\|VERT_FREQ_TAG\|EXPOSURE_TIME_TAG\|EFFECTIVE_EXP_TIME_TAG\|WAITING_TIME_TAG\|RAW_EM_GAIN_TAG\|CAL_EM_GAIN_TAG\|ANALOG_GAIN_TAG\|ANALOG_OFFSET_TAG\|TARGET_DETECTOR_TEMP_TAG\|BINNING_X_TAG\|BINNING_Y_TAG\|ROI_X1_TAG\|ROI_X2_TAG\|ROI_Y1_TAG\|ROI_Y2_TAG\|CROP_MODE_ENABLE_TAG\|CROP_MODE_PADDING_X_TAG\|CROP_MODE_PADDING_Y_TAG\|SHUTTER_MODE_TAG\|TRIGGER_MODE_TAG\|CLAMP_LEVEL_TAG\|PROC_TYPE_TAG\|NBR_PC_IMAGES_TAG\|SERIAL_NUMBER_TAG\|FIRM_VERSION_TAG\|HARDW_VERSION_TAG\|FPGA_VERSION_TAG\|SOFT_VERSION_TAG\|ADD_COMMENTS_TAG\|OVERSCAN_LINES_TAG\|OVERSAMPLE_X_TAG\|DETECTOR_TYPE_TAG\|FIRE_POLARITY_TAG\|SHUTTER_POLARITY_TAG\|ARM_POLARITY_TAG\|OUTPUT_PULSE_WIDTH_TAG\|EXT_SHUTTER_PRES_TAG\|EXT_SHUTTER_MODE_TAG\|EXT_SHUTTER_DELAY_TAG\|OBS_DATE_TAG\|OBS_TIME_SEC_FRACT_TAG\|OBS_FLAGS_TAG\|DATE_TIME_US_TAG\|HOST_TIME_TAG\|NBR_IMAGES_TRIG_TAG\|SEQUENCE_NAME_TAG\)\([^A-Za-z_0-9]\|$\)\)/\1NC.\3/

# Convert standard structures.
s/\(^\|[^A-Za-z_]\)if *(\(.*\)) *{ *$/\1if \2/
s/\(^\|[^A-Za-z_]\)if *(\(.*\)) *{ */\1if \2\n/
s/\(^\|[^A-Za-z_]\)else  *if\([^A-Za-z_]\)/\1elseif\2/
s/} *else\(\|if \)/else\1/
s/ *} */ end /g
s/ *{ */ /g

# Convert operators.
s/>=/≥/g
s/<=/≤/g

# Adjust spaces.
#s/\r/\n/g
s/ *\(=\|==\|!=\|<\|≤\|>\|≥\|<<\|>>\) */ \1 /g
s/ *, */, /g
s/( */(/g
s/ *)/)/g


# Append hold buffer (which may contain a comment) to pattern space and remove
# the inserted newline.
G; s/\n/ /
