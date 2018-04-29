#
# chronologicalAcquisition.jl -
#
# This example demonstrates the usage of the `readChronological` method.  This
# method is always reading the image that is the oldest one in the loop
# buffers.
#
# Please refer to the "simpleAcquisition.jl" example if you're looking for a
# simpler example to acquire images.
#

module ChronologicalAcquisition

# In this example, we want to use the low-level interface as it is the closest
# to the C API.
import NuvuCameras: NC

function main(imageAcquisition::Integer = 40)

    # Opens the acquisition channel using the automatic detection and 4 loop
    # buffers (recommended).
    myCam = NC.open(NC.Cam, NC.AUTO_UNIT, NC.AUTO_CHANNEL, 4)

    # For this example we will not be checking for the available readout modes
    # on the camera and simply assume that the first one is valid.
    NC.setReadoutMode(myCam, 1)

    # Modifies the timeout value to "one second", meaning each image has up to
    # 1 second to reach the frame grabber before the function indicates a
    # timeout.
    NC.setTimeout(myCam, 1000)

    print("Press the Return to start an acquisition sequence of ",
          "$imageAcquisition images;\nas we simulate a long processing time, ",
          "some of the frames in the loop buffers will be overwritten.\n\n",
          "The `readChronological` method will step over these frames to ",
          "read the oldest ones in the loop buffers\n\n")
    readline(STDIN)

    # Open the shutter for the acquisition.
    NC.setShutterMode(myCam, NC.OPEN)

    # Launches 'imageCount' acquisitions by the framegrabber (this function
    # does not wait for the acquisition to be complete before returning).
    NC.start(myCam, imageCount)

    imageCount = imageAcquisition
    i = 0
    while i < imageCount

	# Reads the image received, if a timeout occurs an error code will be
	# returned.
	myImage, nbrImagesSkipped = NC.readChronological(myCam)
        i += 1

	# If you wish to proceed with some processing on each image read, it
	# should be done here (in this example we'll only save the image).

	# Saves each image acquired, at the end of each name the loop index
	# will be added.
	imageName = "Image_$i"

	# Saves the image acquired.
	NC.saveImage(myCam, myImage, imageName, NC.TIF,
                     "This is one of the images grabbed in the chronological example",
                     true)

	println("Number of images skipped to get image $i: ", nbrImagesSkipped)

	# Images that get overwritten are lost from the acquisition sequence
	# Skip that number of lost reads at the end of the sequence.
	imageCount -= nbrImagesSkipped

	# For the purpose of this example we will simulate a processing time
	# that is longer then the acquisition rate (this will depend on the
	# frame rate you currently have set on your camera).  The application
	# will here for a while, allowing for the images coming from the camera
	# to overwrite the previous ones in your loop buffer.
	sleep(0.1)
    end

    println("Total number of images lost from acquisition sequence: ",
            imageAcquisition  - imageCount)

    # Close the shutter, now that the acquistion is complete.
    NC.setShutterMode(myCam, NC.CLOSE)

    # Closes the acquisition channel no longer in use
    NC.close(myCam)

    if is_windows()
	println("\nHit the Return key to close the command window.")
        readline(STDIN)
    else
	println("The program ended.")
    end
end

end # module
