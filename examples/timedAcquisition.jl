#
# timedAcquisition.jl -
#
# This example demonstrates the usage of the `readTimed` method which is
# returning the time at which the exposition ended.
#
# Please refer to the "simpleAcquisition.jl" example if you're looking for a
# simpler example to acquire images.
#

module TimedAcquisition

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main()
    # Opens the acquisition channel using the automatic detection and 4 loop
    # buffers (recommended).
    myCam = NC.open(NC.Cam, NC.AUTO_UNIT, NC.AUTO_CHANNEL, 4)

    # For this example we will not be checking for the available readout modes
    # on the camera and simply assume that the first one is valid.
    NC.setReadoutMode(myCam, 1)

    print("The camera just finished it's initialization, we'll now reset the ",
          "timer and grab a 'timed' image.\n\n")
    readline(STDIN)

    # Open the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Start the timer.
    NC.resetTimer(myCam, 0)

    # Launches an acquisition on the frame grabber and requests an image from
    # the camera (this function does not wait for the acquisition to be
    # complete before returning).
    NC.start(myCam, 1)

    # Reads the image when it's received and records the time; if a timeout
    # occurs an error code will be returned.
    myImage, imageTime = NC.readTimed(myCam) # FIXME: deprecated

    # Close the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    @printf("The time at which the exposure stopped is %f ms ", imageTime)
    print("after the reset of the timer (done just before requesting an ",
          "image from the camera).\n\n")

    NC.saveImage(myCam, myNcImage, "FirstImage", NC.TIF,
                 "This is the first image grabbed in the timed example", true)

    printf("You just acquired one image, by pressing Enter you will ",
           "acquired 15 new images\n")
    readline(STDIN)

    # Open the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches 15 acquisitions on the frame grabber and requests 15 images from
    # the camera (this function does not wait for the acquisition to be
    # complete before returning).
    NC.start(myCam, 15)

    # Loop in which the acquired images are read.
    for i in 1:15

 	# Reads the image received, if a timeout occurs an error code will be
 	# returned.
        myImage, imageTime = NC.readTimed(myCam) # FIXME: deprecated

 	# Checks if an overrun occured on the last image (implying that the
 	# buffer we are reading has been overwritten prior to this "read"
 	# call).
        overrun = NC.getOverrun(myCam)

 	@printf("The time at which the exposition stopped is of %fms ",
                imageTime)
        printf("after the reset of the timer (done just before requesting ",
               "the first image from the camera).\n\n")

 	# If you wish to proceed with some processing on each image read, it
 	# should be done here (in this example we will only save the image).

 	# Saves each image acquired, at the end of each name the loop index
 	# will be added.
 	NC.saveImage(myCam, myNcImage, "Image_$i", NC.TIF,
                     "This is one of the images grabbed in the timed example",
                     true)
    end

    # Close the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Closes the acquisition channel no longer in use.
    NC.CamClose(myCam)

    if is_windows()
	println("\nHit the Return key to close the command window.")
        readline(STDIN)
    else
	println("The program ended.")
    end
end

end # module
