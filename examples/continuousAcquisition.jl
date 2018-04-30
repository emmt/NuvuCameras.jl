#
# continuousAcquisition.jl -
#
# This example demonstrates how to start and acquire images in "free-run" mode
# from the camera.  This example also demonstrates how to save the acquired
# images into data cubes.
#
# Please refer to the "simpleAcquisition.jl" example if you're looking for a
# simpler example to acquire images.
#

module ContinuousAcquisition

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main(nimgs::Int = 0)

    while nimgs ≤ 0
        print("Enter the number of images to acquire: ")
        flush(STDOUT)
        try
            nimgs = parse(Int, readline(STDIN))
        end
    end

    # Opens the acquisition channel using the automatic detection and 4 loop
    # buffers (recommanded).
    myCam = NC.open(NC.Cam, NC.AUTO_UNIT, NC.AUTO_CHANNEL, 4)

    # For this example we will not be checking for the available readout modes
    # on the camera and simply assume that the first one is valid.
    NC.setReadoutMode(myCam, 1)

    # Modifies the timeout value to "one second", meaning each image has up to
    # 1 second to reach the frame grabber before the function indicates a
    # timeout.
    NC.setTimeout(myCam, 1000)

    println("Press the Return key to start a continuous acquisition.")
    print("All the acquired images will be saved in data cubes of $nimgs images.")
    flush(STDOUT)
    readline(STDIN)
    print("\n")

    # Start a separate thread which will save all the acquired images in data cubes.
    NC.startSaveAcquisition(myCam, "NC.Images", NC.FITS, 40, "", 0, true)

    # Open the shutter for the acquisition
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches continuous acquisitions by the framegrabber and the camera (this
    # function does not wait for the acquisition to be complete before
    # returning).
    NC.start(myCam, 0)

    # Loop for the acquisition of each image.
    count = 0
    while count < nimgs
	# Reads the image received, if a timeout occurs an error code will be
 	# returned.
        myImage = NC.read(myCam)

 	# Checks if an overrun occured on the last image (implying that the
 	# buffer we are reading has been overwritten prior to this "read"
 	# call).
        overrun = NC.getOverrun(myCam)

 	# If you wish to proceed with some processing on each image read, it
 	# should be done here (in this example we will only save the image).

 	count += 1
        printf("\rTotal images received: $count")
 	Flush(STDOUT)
    end
    printf("\n") # Preserve printed number of images.

    # Close the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Uses the "abort" function to tell the frame grabber to stop acquiring
    # frames from the camera, also tells the camera to stop sending images to
    # the frame grabber.
    NC.abort(myCam)

    # Stop the separate thread that is saving all the images in data cubes.
    NC.stopSaveAcquisition(myCam)

    # Closes the acquisition channel no longer in use.
    NC.close(myCam)
    if is_windows()
	print("\nHit the Return key to close the command window.")
        flush(STDOUT)
        readline(STDIN)
    else
	println("The program ended.")
    end
end

end # module
