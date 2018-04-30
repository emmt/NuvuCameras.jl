#
# readoutModesAvailability.jl -
#
# This example demonstrates how to list the readout modes available on the
# camera.  The user is then able to able to select one, and grab an image with
# it.
#
# Please refer to the "simpleAcquisition.jl" example if you're looking for a
# simpler example to acquire images.
#

module ReadoutModesAvailability

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main()

    # Opens the acquisition channel using the automatic detection and 4 loop
    # buffers (recommanded).
    myCam = NC.open(NC.Cam, NC.AUTO_UNIT, NC.AUTO_CHANNEL, 4)

    # Investigates about the readout modes available on the camera.
    nmodes = NC.getNbrReadoutModes(myCam)
    println("Here are the available readout modes:\n")
    for i in 1:nmodes
        amptyp, ampstr, vfreq, hfreq = NC.getReadoutMode(myCam, i)
        println(" > Readout mode number $i:")
 	println("   Amplifier type: $ampstr")
        println("   Vertical frequency: $(vfreq)Hz")
        println("   Horizontal frequency: $(hfreq)Hz\n")
    end

    # Second method to inquire the available readout modes, doing so per Ampli type.
    for (typ, descr) in ((NC.CONV, "conventionnal"),
                         (NC.EM,   "EM (electron multiplying)"))
        namplis = NC.getAmpliTypeAvail(myCam, typ)
        if namplis > 0
            println("\nThe $descr amplifier type is supported.")
 	    println("The frequencies supported for this amplifier type are:")
 	    for i in 0:namplis-1
                vfreq, hfreq, modenum = NC.getFreqAvail(myCam, NC.CONV, i)
                println(" > Readout mode number $modenum:")
                println("   Vertical frequency: $(vfreq)Hz")
                println("   Horizontal frequency: $(hfreq)Hz\n")
 	    end
        end
    end

    print("\nPlease select the desired mode you want to load on the camera: ")
    flush(STDOUT)
    modenum = parse(Cint, readline(STDIN))

    NC.setReadoutMode(myCam, modenum)

    println("\nThe readout mode has been successfully loaded on the camera.")
    println("We will now do a dummy grab on the camera and save it to validate it.")
    print("Hit the Return key to start...")
    flush(STDOUT)
    readline(STDIN)

    # Open the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches an acquisition by the framegrabber and requests an image from
    # the camera (this function does not wait for the acquisition to be
    # complete before returning).
    NC.start(myCam, 1)

    # Reads the image received, if a timeout occurs an error code will be
    # returned.
    myImage = NC.read(myCam)

    # Close the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Saves the image acquired
    NC.saveImage(myCam, myNcImage, "NewReadoutImage", NC.TIF,
                 "This is an image grab with the readout mode selected", true)

    println("You just acquired one image, congratulation!.\n")

    # Closes the acquisition channel no longer in use.
    NC.CamClose(myCam)

    if is_windows()
	print("\nHit the Return key to close the command window.")
        flush(STDOUT)
        readline(STDIN)
    else
	println("The program ended.")
    end
end

end # module
