#
# types.jl -
#

"""

All C-API functions yields a value of type `Status`.  Which can be
`NC_SUCCESS` or some error code.

"""
struct Status; code::Cint; end

"""

Abstract type `Handle` is the super type of all types used to store the
address of an opaque sructure.  All such types have a filed `ptr` with the
pointer.

"""
abstract type Handle end

# Beware, this it is more convenient to define NcImageSaved and NcStatsCtx
# as being pointer rather than structures (FIMXE: check).

for T in (:NcCam, :NcGrab, :ImageParams, :NcProc,
          :NcCtrlList, :NcCropModeSolutions,
          :NcImageSaved, :NcStatsCtx, :NcCtxSaved)
    @eval begin

        struct $T <: Handle; ptr::Ptr{Void}; end

        @doc @doc(Handle) $T

    end
end

# typedef unsigned short NcImage;
const NcImage = Cushort

# Alias for a callback returning nothing.
const VoidCallback = Ptr{Void}

# typedef void(*NcCallbackFunc)(void*);
const NcCallbackFunc = Ptr{Void}


struct TmStruct
    tm_sec::Cint         # Seconds.     [0-60] (1 leap second)
    tm_min::Cint         # Minutes.     [0-59]
    tm_hour::Cint        # Hours.       [0-23]
    tm_mday::Cint        # Day.         [1-31]
    tm_mon::Cint         # Month.       [0-11]
    tm_year::Cint        # Year - 1900.
    tm_wday::Cint        # Day of week. [0-6]
    tm_yday::Cint        # Days in year.[0-365]
    tm_isdst::Cint       # DST.         [-1/0/1]
    tm_gmtoff::Clong     # Seconds east of UTC.
    tm_zone::Ptr{Cchar}  # Timezone abbreviation.
end

#
#
#  typedef fitsfile NcCtxSaved;
#
#  typedef struct _NcDevice* NcDevice;
