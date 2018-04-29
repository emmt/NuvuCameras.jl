#
# simpleAcquisition.jl -
#
# This is the simplest one from the available examples.  It shows the user how
# to start the acquisition of multiples images, how to read the images and to
# detect if an overrun or even a timeout happened.
#
# This example also explains how to save acquired images.
#

module SimpleAcquisition

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main()
    saveFormat = NC.FITS

    # Opens the acquisition channel using the automatic detection and 4 loop
    # buffers (recommended).
    myCam = NC.open(NC.Cam, NC.AUTO_UNIT, NC.AUTO_CHANNEL, 4)

    # For this example we will not bother checking for the available readout
    # modes on the camera and simply assume that the first one is valid.
    NC.setReadoutMode(myCam, 1)

    # Recover the readout time for use later.
    readoutTime = NC.getReadoutTime(myCam)

    # We set a non-zero exposure so that the first image is not blank.
    NC.setExposureTime(myCam, readoutTime)

    # Recover the exposure time for use later.
    exposureTime = NC.getExposureTime(myCam, true)

    # We set a reasonable waiting time.
    NC.setWaitingTime(myCam, 0.1*exposureTime)

    # Recover the waiting time for use later.
    waitingTime = NC.getWaitingTime(myCam, true)

    # Set a reasonable timeout on reading an image.  The delay between images
    # is the sum of the waiting time, the exposure and the readout time (if the
    # waiting time is non-zero).
    NC.setTimeout(myCam, waitingTime + exposureTime + readoutTime + 1000.0)

    # Opens the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches an acquisition on the frame grabber and requests images from the
    # camera (this function does not wait for the acquisition to be complete
    # before returning).
    NC.start(myCam, 0)

    # Reads a single received image: if a timeout occurs an error code will be
    # returned.
    myImage = NC.read(myCam)

    # Uses the "abort" function to tell the frame grabber to stop acquiring
    # frames from the camera, also tells the camera to stop sending images to
    # the frame grabber.
    NC.abort(myCam)

    # Closes the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Saves the image acquired
    NC.saveImage(myCam, myImage, "FirstImage", saveFormat,
                 "This is my first image grabbed", true)

    println("You just acquired one image, by pressing Enter you will acquire 15 new images")
    readline(STDIN)

    # Opens the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches 15 acquisitions on the frame grabber and requests 15 images from
    # the camera (this function does not wait for the acquisition to be
    # complete before returning).
    NC.start(myCam, 15)

    # Loop in which acquired images are read.
    for i in 1:15
	# Reads the image received, if a timeout occurs an error code will be
	# returned.
	myImage = NC.read(myCam)

	# Checks if an overrun occured on the last image (implying that the
	# buffer we are reading has been overwritten prior to this "read"
	# call).
	overrun = NC.getOverrun(myCam)

	# If you wish to proceed with some processing on each image read, it
	# should be done here (in this example we will only save the image).


	# Saves each image acquired, at the end of each name the loop index
	# will be added.
	imageName = "Image_$i"
	NC.saveImage(myCam, myImage, imageName, saveFormat,
                     "This is my first series of images grabbed", true)
	println("Saved ", imageName)
    end

    # Closes the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Closes the acquisition channel no longer in use.
    NC.close(myCam)

    if is_windows()
	println("\nHit the Return key to close the command window.")
        readline(STDIN)
    else
	println("The program ended.")
    end
end

end # module
