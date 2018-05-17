/*
 * ncacquire.c -
 *
 * Acquire image(s) with Nüvü Camēras.
 */

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "nc_driver.h"

#undef DEBUG_MODE

const char* progname = "acquire";

#define TRY(func,args) do {                     \
    int status = func args;                     \
    if (status != NC_SUCCESS) {                 \
      failure(#func, status);                   \
    }                                           \
  } while (0)

static void failure(const char* func, int status)
{
  fprintf(stderr, "%s: function `%s` failed with code %d\n",
          progname, func, status);
  exit(1);
}

static void parseint(const char* str, int* ptr)
{
  char c;
  if (sscanf(str, " %d %c", ptr, &c) != 1) {
    fprintf(stderr, "%s: bad integer value `%s`\n", progname, str);
    exit(1);
  }
}

static int skipspaces(const char* str, int i)
{
  while (str[i] != '\0' && isspace(str[i])) {
    ++i;
  }
  return i;
}

static int scandecimal(const char* str, int i0, int* ptr)
{
  int i = skipspaces(str, i0);
  if ('0' <= str[i] && str[i] <= '9') {
    int val = (str[i] - '0');
    while ('0' <= str[++i] && str[i] <= '9') {
      val = 10*val + (str[i] - '0');
    }
    *ptr = val;
    return i;
  } else {
    return i0;
  }
}

static void parseinterface(const char* interface, int* unitptr, int* channelptr)
{
  int unit, channel;
  const char* tail;

  tail = NULL;
  channel = NC_AUTO_CHANNEL;
  if (interface == NULL || strcmp(interface, "auto") == 0) {
    unit = NC_AUTO_UNIT;
  } else if (strcmp(interface, "virtual") == 0) {
    unit = VIRTUAL;
    channel = VIRTUAL;
  } else if (strncmp(interface, "pleora", 6) == 0) {
    unit = PT_GIGE;
    tail = interface + 6;
  } else if (strncmp(interface, "edt", 3) == 0) {
    unit = EDT_CL;
    tail = interface + 3;
  } else {
    fprintf(stderr, "%s: unknown interface `%s`\n", progname, interface);
    exit(1);
  }
  if (tail != NULL) {
    int board, i;
    board = 0;
    i = skipspaces(tail, 0);
    if (tail[i] == ':') {
      i = scandecimal(tail, i + 1, &board);
      i = skipspaces(tail, i);
      if (tail[i] == ':') {
        i = scandecimal(tail, i + 1, &channel);
        i = skipspaces(tail, i);
      }
    }
#ifdef DEBUG_MODE
    printf("board=%d, channel=0x%08x\n", (int)board, (unsigned int)channel);
#endif
    if (tail[i] != '\0') {
      fprintf(stderr, "%s: bad interface board/channel `%s`\n", progname, interface);
      exit(1);
    }
    if (board < 0) {
      fprintf(stderr, "%s: bad board number `%d`\n", progname, board);
      exit(1);
    }
    if (channel < 0) {
      fprintf(stderr, "%s: bad channel number `%d`\n", progname, channel);
      exit(1);
    }
    unit += board;
  }
  *unitptr = unit;
  *channelptr = channel;
}

int main(int argc, char* argv[])
{
  NcCam	cam = NULL;
  NcImage *img;
  int overwrite = 1;
  int continuous = 1;
  enum ImageFormat format = FITS;
  int i;
  int overrun = 0;
  int nbufs = 4;
  double readoutTime, waitingTime, exposureTime;
  double temperature;
  int timeout;
  char path[2028];
  const char* interface;
  int unit, channel;
  const char* prefix;
  int nimgs;

  if (argc < 2 || argc > 4) {
    fprintf(stderr, "Usage: %s INTERFACE [PREFIX [NUMBER]\n\n", progname);
    fprintf(stderr, "INTERFACE is one of:\n");
    fprintf(stderr, "  auto       to automatically use the first connected camera;\n");
    fprintf(stderr, "  virtual    to use the virtual camera;\n");
    fprintf(stderr, "  GRAB:[BOARD][:CHANNEL]\n");
    fprintf(stderr, "             to use the frame grabber of type GRAB (edt, pleora, ...);\n");
    fprintf(stderr, "             BOARD can be specified to choose another board number than\n");
    fprintf(stderr, "             the default which is 0 (corresponding to the first board of\n");
    fprintf(stderr, "             the given frame grabber type), CHANNEL can specified to choose\n");
    fprintf(stderr, "             another channel number than the one automatically found;\n");
    fprintf(stderr, "PREFIX is the image name prefix (\"img-\" by default)\n");
    fprintf(stderr, "NUMBER is the number of images to acquire (1 by default)\n");

    return 1;
  }

  interface = argv[1];
  prefix = (argc >= 3 ? argv[2] : "img-");
  nimgs = 1;
  if (argc >= 4) {
    parseint(argv[3], &nimgs);
  }
  parseinterface(interface, &unit, &channel);
  fprintf(stderr, "acquisition of %d image(s) for unit=0x%08x, channel=0x%08x\n",
          nimgs, (unsigned int)unit, (unsigned int)channel);
  if (nimgs < 1) {
    return 0;
  }

  // Opens the acquisition channel.
  TRY(ncCamOpen,(unit, channel, nbufs, &cam));

  // For this example we will not bother checking for the available readout
  // modes on the camera and simply assume that the first one is valid
  TRY(ncCamSetReadoutMode,(cam, 1));

  // Recover the readout time for use later
  TRY(ncCamGetReadoutTime,(cam, &readoutTime));

  // We set a non-zero exposure so that the first image is not blank
  TRY(ncCamSetExposureTime,(cam, readoutTime));

  // Recover the exposure time for use later
  TRY(ncCamGetExposureTime,(cam, 1, &exposureTime));

  // We set a reasonable waiting time
  TRY(ncCamSetWaitingTime,(cam, 0.1 * exposureTime));

  // Recover the waiting time for use later
  TRY(ncCamGetWaitingTime,(cam, 1, &waitingTime));

  // Set a reasonable timeout on reading an image The delay between images is
  // the sum of the waiting time, the exposure and the readout time
  // (if the waiting time is non-zero).
  TRY(ncCamSetTimeout,(cam, waitingTime + exposureTime + readoutTime + 1000.0));

  TRY(ncCamGetTimeout,(cam, &timeout));

  fprintf(stderr, "\n");
  fprintf(stderr, "Readout time   %10.3f ms\n", readoutTime);
  fprintf(stderr, "Exposure time: %10.3f ms\n", exposureTime);
  fprintf(stderr, "Waiting time:  %10.3f ms\n", waitingTime);
  fprintf(stderr, "Timeout:       %10.3f ms\n", (double)timeout);
  fprintf(stderr, "\n");
  TRY(ncCamGetComponentTemp,(cam, NC_TEMP_CCD, &temperature));
  fprintf(stderr, "CCD temperature:          %10.3f °C\n", temperature);
  TRY(ncCamGetComponentTemp,(cam, NC_TEMP_CONTROLLER, &temperature));
  fprintf(stderr, "Controller temperature:   %10.3f °C\n", temperature);
  TRY(ncCamGetComponentTemp,(cam, NC_TEMP_POWER_SUPPLY, &temperature));
  fprintf(stderr, "Power supply temperature: %10.3f °C\n", temperature);
  TRY(ncCamGetComponentTemp,(cam, NC_TEMP_FPGA, &temperature));
  fprintf(stderr, "FPGA temperature:         %10.3f °C\n", temperature);
  TRY(ncCamGetComponentTemp,(cam, NC_TEMP_HEATINK, &temperature));
  fprintf(stderr, "Heatink temperature:      %10.3f °C\n", temperature);
  fprintf(stderr, "\n");

  // Opens the shutter for the acquisition
  TRY(ncCamSetShutterMode,(cam, OPEN));

  // Launches an acquisition on the frame grabber and requests images from the
  // camera (this function does not wait for the acquisition to be complete
  // before returning).  With a number of images set to 0, continuous acquisition
  // is started.
  if (continuous) {
    TRY(ncCamStart,(cam, 0));
  } else {
    TRY(ncCamStart,(cam, nimgs));
  }

  //Loop in which acquired images are read
  for (i = 1; i <= nimgs; ++i) {
    // Reads the image received, if a timeout occurs an error code will be
    // returned.
    TRY(ncCamRead,(cam, &img));

    // Checks if an overrun occured on the last image (implying that the
    // buffer we are reading has been overwritten prior to this "read" call).
    TRY(ncCamGetOverrun,(cam, &overrun));

    // If you wish to proceed with some processing on each image read, it
    // should be done here (in this example we will only save the image).

    // Saves each image acquired, at the end of each name the loop index will
    // be added.
    sprintf(path, "%s%06d", prefix, i);
    TRY(ncCamSaveImage,(cam, img, path, format, "", overwrite));
  }

  if (continuous) {
    // Uses the "abort" function to tell the frame grabber to stop acquiring
    // frames from the camera, also tells the camera to stop sending images to
    // the frame grabber.
    TRY(ncCamAbort,(cam));
  }

  // Closes the shutter, now that the acquistion is complete.
  TRY(ncCamSetShutterMode,(cam, CLOSE));

  //Closes the acquisition channel no longer in use.
  TRY(ncCamClose,(cam));
  return 0;
}
