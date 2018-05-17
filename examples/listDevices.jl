module ListDevices

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main(; basic::Bool=true)

    ctrl = NC.open(NC.CtrlList, basic)

    try

        numcontrollers = NC.getSize(ctrl)
        println("$numcontrollers controller(s) found")
        for i in 0:numcontrollers-1
            serial = NC.getSerial(ctrl, i)
            model = NC.getModel(ctrl, i)
            portunit = NC.getPortUnit(ctrl, i)
            portchannel = NC.getPortChannel(ctrl, i)
            portinterface = NC.getPortInterface(ctrl, i)
            uniqueid = NC.getUniqueID(ctrl, i)
            fullwidth, fullheight = NC.getFullSize(ctrl, i)
            detectorwidth, detectorheight = NC.getDetectorSize(ctrl, i)
            detectortype = NC.getDetectorType(ctrl, i)
            println("  $i: Model ------------> ", model)
            println("  $i: Serial -----------> ", serial)
            println("  $i: Port interface ---> ", portinterface)
            println("  $i: Port unit --------> ", portunit)
            println("  $i: Port channel -----> ", portchannel)
            println("  $i: Unique ID --------> ", uniqueid)
            println("  $i: Detector type ----> ", detectortype)
            println("  $i: Full size --------> ", fullwidth, " × ", fullheight)
            println("  $i: Detector size ----> ", detectorwidth, " × ", detectorheight)
        end
        println()

        numfreeports = NC.getFreePortCount(ctrl)
        println("$numfreeports free port(s) found")
        for i in 0:numfreeports-1
            println("  $i: Port interface ---> ", NC.getFreePortInterface(ctrl, i))
            println("  $i: Port unit --------> ", NC.getFreePortUnit(ctrl, i))
            println("  $i: Port channel -----> ", NC.getFreePortChannel(ctrl, i))
            println("  $i: Unique ID --------> ", NC.getFreePortUniqueID(ctrl, i))
        end
        println()

        numplugins = NC.getPluginCount(ctrl)
        println("$numplugins plugin(s) found")
        for i in 0:numplugins-1
            pluginname = NC.getPluginName(ctrl, i)
            println("  $i: Plugin name ------> ", NC.getPluginName(ctrl, i))
        end

    finally
        NC.close(ctrl)
    end
end

end # module
